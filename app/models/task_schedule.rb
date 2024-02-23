
class TaskSchedule < ActiveRecord::Base

	belongs_to :schedule
	belongs_to :task

	def self.prepare_params(params)
		{
			schedule: Schedule.find(params["schedule"]),
			task: 		Task.find(params["task"]),
			number: 	params["number"],
			s_time: 	DateTime.strptime(params["s_time"],"%H:%M"),
			e_time: 	DateTime.strptime(params["e_time"],"%H:%M")
		}
	end

end
