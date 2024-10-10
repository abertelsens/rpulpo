
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
		super(Task.prepare_params params, self)
	end

	def self.prepare_params(params, task=nil)
		{
			name: 												params[:name],
			priority: 										params[:priority],
			task_schedules_attributes:		Task.prepare_task_schedules_attributes(params, task)
		}
	end

	# creates an array of parameters that coan be used to create a TaslSchedule object
	def self.prepare_task_schedules_attributes(params, task=nil)
		schedule_ids = params[:number].keys
		task_schedule_ids = (task.task_schedules.map{|ts| { ts.schedule_id => ts.id } }).inject(:merge) if task
		schedule_ids.map do |schedule_id|
			{
				id:						task_schedule_ids[schedule_id.to_i],
				task_id:      task.id,
				schedule_id:  schedule_id,
				number:       params[:number][schedule_id],
				points:       params[:points][schedule_id],
				s_time:       Task.parse_time(params[:s_time][schedule_id]),
				e_time:       Task.parse_time(params[:e_time][schedule_id]),
				notes:        params[:notes][schedule_id]
			}
		end
	end

	def self.create_default()
		task = method(:create).super_method.call(name: "new task #{rand(1000)}", priority: 1)
		Schedule.all.each { |sch| TaskSchedule.create_default(task, sch) }
		task
	end

  def self.parse_time(time_string)
		DateTime.strptime(time_string,"%H:%M") unless time_string.blank?
  end

end
