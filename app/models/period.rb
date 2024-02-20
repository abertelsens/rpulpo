# Google calendar API key AIzaSyA-3PoZaonvgyax2wkRPVGsze0O7ZKJL1A
class DateType < ActiveRecord::Base#
	belongs_to	:day_type
	belongs_to	:period
  has_many    :task_assignment
end

class Period < ActiveRecord::Base
  has_many  :date_type

	def self.prepare_params(params)
		{
			name: params["name"],
			s_date: 	Date.parse(params["s_date"]),
			e_date: 	Date.parse(params["e_date"])
		}
	end

  def create_days
    default_day_type = DayType.find_by(name:"L")
    (s_date..e_date).each do |date|
      DateType.create(period: self, date: date, day_type: default_day_type) unless DateType.find_by(date: date)
    end
  end

  def get_days
    DateType.where(:date => s_date..e_date)
  end

  def self.get_tasks(task_assignments, task, date)
    task_assignments.where(task: task, date: date).pluck(:person)
  end

  def get_task_assignments
    set = TaskAssignment.includes(:person, :task, :day_type)
    .joins(:date_type)
    .where(date_type: {period: self})
    .pluck("date_type.date", "tasks.id", "tasks.name", "people.short_name")
    puts Rainbow(set.inspect).red
    return set
  end


end
