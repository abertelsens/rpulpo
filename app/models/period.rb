# Google calendar API key AIzaSyA-3PoZaonvgyax2wkRPVGsze0O7ZKJL1A

class Period < ActiveRecord::Base

  has_many  :day_schedules, dependent: :destroy
  has_many  :task_assignments, :through => :day_schedules

	def self.prepare_params(params)
		{
			name: params["name"],
			s_date: 	Date.parse(params["s_date"]),
			e_date: 	Date.parse(params["e_date"])
		}
	end

  def create_days
    default_schedule = Schedule.find_by(name:"L")
    (s_date..e_date).each do |date|
      puts "creating schedules for "
      puts date.strftime("%A %m/%d/%Y")
      ds = DaySchedule.create(period: self, date: date, schedule: default_schedule)
    end
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
    available_people = Person.where(student: true, ctr: "cavabianca")
    people_size = available_people.size
    tasks = Task.all
    day_schedules.each do |ds|
      tasks.each do |task|
        person = available_people[rand(0..people_size-1)]
        TaskAssignment.create(day_schedule: ds, task: task, person: person)
      end
    end
  end

  # gets all the day_schedules of the week corresponding to a a sepcific date
  def get_week(week_index)
    datesByWeekday = (s_date..e_date).group_by(&:wday)
    first_monday = datesByWeekday[1][week_index-1] # first monday
    return nil if first_monday.nil?
    first_monday = first_monday -7 if (first_monday > s_date)
    puts "\n\n\n\n\nfirst monday"
    puts first_monday.strftime("%A %m/%d/%Y")
    puts "end_date"
    puts (first_monday+6).strftime("%A %m/%d/%Y")
    puts "\n\n\n\n\n"
    ds = DaySchedule.where(:date => first_monday..first_monday+6)
  end

  def contains?(ds)
    puts "cheking if #{ds.date} is between  #{s_date} and  #{e_date}"
    puts ds.date.between?(s_date,e_date)
    return ds.date.between?(s_date,e_date)
  end
end
