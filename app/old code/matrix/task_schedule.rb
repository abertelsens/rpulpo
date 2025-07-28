
# Google calendar API key AIzaSyA-3PoZaonvgyax2wkRPVGsze0O7ZKJL1A

# task?schedule.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-10-05
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defining an period object.
#---------------------------------------------------------------------------------------

class TaskSchedule < ActiveRecord::Base

	belongs_to 	:schedule
	belongs_to 	:task

	has_many 		:task_assignments, dependent: :destroy

	# the default scoped defines the default sort order of the query results
	default_scope { order(schedule_id: :asc) }

	AM_HOUR_LIMIT = 14
	PM1_HOUR_LIMIT = 17

	def self.create_from_array params_array
		params_array.each do |params|
			ts = TaskSchedule.find_by(task: params[:task], schedule_id:params[:schedule_id])
			ts.nil? ? (TaskSchedule.create params) : (ts.update params)
		end
	end

	def get_time
		time = (e_time.hour<=AM_HOUR_LIMIT) ? "AM" : (s_time<=AM_HOUR_LIMIT ? "ALL": "PM")
		time
	end

	def self.find_task_schedule(task,day_schedule)
		TaskSchedule.find_by(task:task, schedule:day_schedule.schedule)
	end

	def self.create_default(task,schedule)
		TaskSchedule.create(task: task, schedule: schedule)
	end

	def overlaps?(task_schedule)
		(s_time..e_time).overlap?(task_schedule.s_time..task_schedule.e_time)
	end
end
