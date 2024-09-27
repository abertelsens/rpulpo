# Google calendar API key AIzaSyA-3PoZaonvgyax2wkRPVGsze0O7ZKJL1A

class Period < ActiveRecord::Base

  has_many  :day_schedules, dependent: :destroy
  has_many  :task_assignments, :through => :day_schedules

  # callback before update. We check if the period dates have changed.
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

  def create_days
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
            person = people_available[rand(0..people_size-1)]
            TaskAssignment.create(day_schedule: ds, task: task, person: person)
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
end
