# A class that defines the schedule of a specific date.

class DaySchedule < ActiveRecord::Base#

  belongs_to	:schedule
  belongs_to	:period
  has_many    :task_assignments, dependent: :destroy
  has_many    :task_schedules, :through => :schedule
  has_many    :tasks, :through => :task_schedules

  scope :of_period, ->(period_id) { where("period_id = ?", period_id) }

   # get the number of people needed for a specific task
   def get_number(task)
    task_schedules.find_by(task: task).number
  end

  def get_task_schedule(task)
    TaskSchedule.find_by(task:task, schedule:day_schedule.schedule)
  end

  # gets all the assignments of a given task
  def get_task_assignments(task)
    task_assignments.includes(:person).joins(:task_schedule).where(task_schedule: {task_id: task.id})
  end

  def get_task_assignments_to_html(task)
    tas = get_task_assignments(task)
    tas.empty? ? "-" : tas.map {|ta| ta.person.short_name }.join("<br>")
  end

  def get_assigned_people(task)
    get_task_assignments(task).map {|ta| ta.person}
  end

  def get_number_of_assigned_people(task)
    get_task_assignments(task).size
  end

  def create_assignments()
    Task.all.each {|task| TaskAssignment.create(day_schedule: self, task: task)}
  end

  # checks the status of the assignments for a specific task
  def get_assignment_status_class(task)
    people_assigned = get_task_assignments(task).size
    people_to_assign = (TaskSchedule.find_task_schedule task, self).number
    people_needed = people_to_assign-people_assigned
    return "matrix-cell-ok" if people_needed==0
    return "matrix-cell-missing" if people_needed>0
    return "matrix-cell-over" if people_needed<0
  end
end
