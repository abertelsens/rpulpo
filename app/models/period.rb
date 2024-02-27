# Google calendar API key AIzaSyA-3PoZaonvgyax2wkRPVGsze0O7ZKJL1A

class Period < ActiveRecord::Base

  has_many  :day_schedules
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
      DaySchedule.create(period: self, date: date, schedule: default_schedule) unless DaySchedule.find_by(date: date)
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


end
