# A class that defines the schedule of a specific date.

class DaySchedule < ActiveRecord::Base#
	belongs_to	:schedule
  belongs_to	:period
  has_many    :task_assignments
  has_many    :task_schedules, :through => :schedule
  has_many    :tasks, :through => :task_schedules

  def get_task_assignments(task)
    task_assignments.includes(:person).where(task: task.id)
  end

  def get_number(task)
    task_schedules.find_by(task: task).number
  end

  def get_task
    task.order(name: :asc)
  end
end
