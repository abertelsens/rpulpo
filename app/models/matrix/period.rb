# Google calendar API key AIzaSyA-3PoZaonvgyax2wkRPVGsze0O7ZKJL1A

class Period < ActiveRecord::Base

  has_many  :day_schedules, dependent: :destroy
  has_many  :task_assignments, :through => :day_schedules
  has_many  :period_points, dependent: :destroy

  after_create :create_period_days

  # callback before update. We check if the period dates have changed
  before_update do
    old_period = (self.s_date_was..self.e_date_was).to_a
    new_period = (self.s_date..self.e_date).to_a
    default_schedule = Schedule.find_by(name:"L")
    (new_period-old_period).each {|date| DaySchedule.create(period: self, date: date, schedule: default_schedule)}
    (old_period-new_period).each {|date| DaySchedule.find_by(date: date).destroy}
  end

  	def self.prepare_params(params)
		{
			name: params["name"],
			s_date: 	Date.parse(params["s_date"]),
			e_date: 	Date.parse(params["e_date"])
		}
	end

  def create_period_days
    puts "creating days for period"
    default_schedule = Schedule.find_by(name:"L")
    (s_date..e_date).each {|date| DaySchedule.create(period: self, date: date, schedule: default_schedule)}
  end


  def get_days
    DateType.where(:date => s_date..e_date)
  end

  def self.get_tasks(task_assignments, task, date)
    task_assignments.where(task: task, date: date).pluck(:person)
  end

  def get_task_assignments
    task_assignments.includes(:person, :task, :day_schedule)
    .pluck("day_schedules.date", "tasks.id", "tasks.name", "people.short_name")
  end

  def assign_all_tasks
    tasks = Task.all

    day_schedules.each do |ds|
      tasks.each do |task|
        people_available = PersonPeriod.find_people_available ds, task
        if !people_available.empty?
          people_size = people_available.size
          ts = TaskSchedule.find_by(task: task, schedule: ds.schedule)
          num = 0 if ts.nil?
          num = ts.number - ds.get_number_of_assigned_people(task)
          index = 0
          while (index < num && people_size>0)
            #person = people_available[rand(0..people_size-1)]
            person = get_min_points_person people_available
            puts "found minimal person\n----------------"
            puts person.inspect
            puts "-----------------------"
            TaskAssignment.create(day_schedule: ds, task_schedule: ts, person: person)
            pp = PeriodPoint.find_by(person: person, period: self)
            pp.update_points
            index = index +1
            people_available = people_available - [person]
            people_size = people_available.size
          end
        end
      end
    end
  end


  # gets all the day_schedules of the week corresponding to a a sepcific date
  def get_week(week_index)

    monday = get_previous_day(s_date,1) + (week_index-1) * 7
    return DaySchedule.where(:date => monday..monday+6).order(date: :asc)

  end

  def get_previous_day(date, day_of_week)
    date - ((date.wday - day_of_week) % 7)
  end


  def contains?(ds)
    puts "cheking if #{ds.date} is between  #{s_date} and  #{e_date}"
    puts ds.date.between?(s_date,e_date)
    return ds.date.between?(s_date,e_date)
  end


  def get_assignments_time(person)
    task_assignments.where(person:person).inject(0){|sum, ta| sum + ta.get_assignment_time}
  end

  def update_points(person)
    period_points.find_by(person: person).update_points
  end

  def get_min_points(people=nil)
    return people if !PersonPeriod.any?
    mp_people = if people.nil?
      PeriodPoint.where(points: period_points.minimum(:points))
    else
      PeriodPoint.joins(people).where(points: period_points.minimum(:points))
    end
    return people if mp_people.empty? #if none is found then we return the list as we got ti
    Person.where(id: mp_people.pluck(:person_id))
  end

  # gets the next avaible person with minimum points
  def get_min_points_person(people=nil)
    people = get_min_points(people)
    people[rand(0..people.size-1)]
  end

end


class PeriodPoint < ActiveRecord::Base

  belongs_to :period
  belongs_to :person

  default_scope { order(points: :asc) }

  # update the points for a given person
  def update_points
    points = TaskAssignment.includes(:task_schedule).joins(:day_schedule).where(day_schedule: {period: period.id}).where(person: person).sum(:points)
    update(points: points)
  end

  def self.get_points(period,person)
    pp = PeriodPoint.find_by(period:period, person:person)
    pp.nil? ? 0 : pp.points
  end

end
