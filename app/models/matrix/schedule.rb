# schedule.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-10-05
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defining a schedule object.
#---------------------------------------------------------------------------------------

class Schedule < ActiveRecord::Base

	has_many	:task_schedules, 	dependent: :destroy
	has_many	:day_schedules, 	dependent: :destroy

	default_scope { order(name: :asc) }

	# -----------------------------------------------------------------------------------------
	# CRUD METHODS
	# -----------------------------------------------------------------------------------------
 
	def self.create(params)
		super(Schedule.prepare_params params)
	end

	def update(params)
		super(Schedule.prepare_params params)
	end

	def self.prepare_params(params)
	{
		name: 				params[:name],
		description: 	params[:description]
	}
	end

	# -----------------------------------------------------------------------------------------
	# ACCESSORS
	# -----------------------------------------------------------------------------------------

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
