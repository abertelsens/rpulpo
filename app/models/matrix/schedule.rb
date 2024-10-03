class Schedule < ActiveRecord::Base

	has_many	:task_schedules, dependent: :destroy
	has_many	:day_schedules, dependent: :destroy


	def self.create_update(params)
		@schedule = (params[:id]=="new" ? nil : Schedule.find(params[:id]))
		@schedule.nil? ? Schedule.create(prepare_params params) : @schedule.update(prepare_params params)
	end

	def self.prepare_params(params)
	{
		name: params[:name],
		description: params[:description]
	}
	end

	def self.get_all
		Schedule.all.order(name: :asc)
	end

	def get_task_schedules
		task_schedules.includes(:task).joins(:task).order("tasks.name asc")
	end

	def get_task_schedule task
		task_schedules.includes(:task).find_by(task: task)
	end

	def to_s
		"#{name} - #{description}"
	end

end
