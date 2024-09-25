
class TaskSchedule < ActiveRecord::Base

	belongs_to :schedule
	belongs_to :task

	def self.create_from_array params_array
		params_array.each do |params|
			ts = TaskSchedule.find_by(task: params[:task], schedule_id:params[:schedule_id])
			if ts.nil?
				TaskSchedule.create(params)
			else
				ts.update params
			end
		end
	end

	def get_time
		(e_time.hour<=14) ? "AM" : "PM"
	end

	def self.find_task_schedule(task,day_schedule)
		TaskSchedule.find_by(task:task, schedule:day_schedule.schedule)
	end
end
