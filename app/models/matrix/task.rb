
# task.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION
# A class defining a Task object.
# -----------------------------------------------------------------------------------------

class Task < ActiveRecord::Base

	# each task can have many schedules depending on the type of day
  has_many :task_schedules, dependent: :destroy

	accepts_nested_attributes_for :task_schedules #, allow_destroy: true

	# the default scoped defines the default sort order of the query results
	default_scope { order(name: :asc) }

	def self.create(params)
		super(Task.prepare_params params)
	end

	def update(params)
		super(Task.prepare_params params, self )
	end

	def self.prepare_params(params)
		{
			name: 												params[:name],
			priority: 										params[:priority],
			task_schedules_attributes:		Task.prepare_task_schedules_attributes(params, task)
		}
	end
	
	# creates an array of parameters that coan be used to create a TaslSchedule object
	def prepare_task_schedules_attributes(params, task=nil)
		# if task is nil then we are creating the task_schedules. We create the task_schedules
		# with the schedule_id and the task_id
		# If the task exists we need to update the task_schedules, therefore we retrieve the 
		# task_schedules_ids and create a hash 
		if task.nil?
			schedule_ids = params[:number].keys
		else
			task_schedule_ids = (task_schedules.map{|ts| ts.schedule_id => ts.task_id }).inject(:merge)
		end
		schedule_ids.map do |schedule_id|
			hash =	{
				task:         self,
				number:       params[:number][schedule_id],
				points:       params[:points][schedule_id],
				s_time:       parse_time(params[:s_time][schedule_id]),
				e_time:       parse_time(params[:e_time][schedule_id]),
				notes:        params[:notes][schedule_id]
			}
			task.nil? ? (hash[:schedule_id] = schedule_id) : (hash[:id] = task_schedule_ids[:schedule_id])
		end
	end

  def parse_time(time_string)
		DateTime.strptime(time_string,"%H:%M") unless time_string.blank?
  end

end
