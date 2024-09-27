
class TaskSchedule < ActiveRecord::Base

	belongs_to :schedule
	belongs_to :task

	AM_HOUR_LIMIT = 14

	def self.create_from_array params_array
		params_array.each do |params|
			ts = TaskSchedule.find_by(task: params[:task], schedule_id:params[:schedule_id])
			ts.nil? ? (TaskSchedule.create params) : (ts.update params)
		end
	end

	def get_time
		(e_time.hour<=AM_HOUR_LIMIT) ? "AM" : (s_time<=AM_HOUR_LIMIT ? "ALL": "PM")
	end

	def self.find_task_schedule(task,day_schedule)
		TaskSchedule.find_by(task:task, schedule:day_schedule.schedule)
	end
end
