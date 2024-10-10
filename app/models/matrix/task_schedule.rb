
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
end
