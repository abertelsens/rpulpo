
class TaskSchedule < ActiveRecord::Base

	belongs_to :schedule
	belongs_to :task

	def self.create_from_array params_array
		params_array.each do |params|
		end
			ts = TaskSchedule.find_by(task: params[:task], schedule_id:params[:schedule_id])
			if ts.nil?
				TaskSchedule.create(params)
			else
				ts.update params
			end
	end

end
