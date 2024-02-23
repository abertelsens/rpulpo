class Schedule < ActiveRecord::Base

	has_many	:task_schedules
	has_many	:day_schedules

	def to_s
		"#{name} - #{description}"
	end

	def get_task_schedules
		task_schedules.includes(:task).joins(:task).order("tasks.name asc")
	end

	def get_task_schedule task
		task_schedules.includes(:task).find_by(task: task)
	end

end
