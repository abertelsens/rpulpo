###########################################################################################
# A class defining a correo entry.
###########################################################################################
require 'rubyXL'

class Task < ActiveRecord::Base
end

class DayType < ActiveRecord::Base
	has_one	:task_type
end



class TaskType < ActiveRecord::Base
	belongs_to :day_type
	belongs_to :task

	def self.prepare_params(params)
		{
			day_type: DayType.find(params["day_type"]),
			task: 		Task.find(params["task"]),
			s_time: 	DateTime.strptime(params["s_time"],"%H:%M"),
			e_time: 	DateTime.strptime(params["e_time"],"%H:%M")
		}
	end

end

class TaskAssignment < ActiveRecord::Base
	belongs_to 	:person
	belongs_to 	:task
	belongs_to 	:date_type #, :source => :date
	has_one 		:day_type, :through => :date_type
	has_one			:task_type, :through => :day_type, :source => :task_type

	#def self.create_from_params(params)
	#	create(person: params[:person], task: params[:task], day_day_type: day_day_type)
	#end

	def get_date_type
		puts "found date_type.id #{date_type.id} date_type.date #{date_type.date}"
		puts day_type.name
	end

	def get_task_type
		puts task_type.s_time
		puts task_type.e_time
	end

	def self.assign(task, date_type, person)
			ta = TaskAssignment.find_by(date_type: date_type, task: task)
			ta.nil? ? TaskAssignment.create(date_type: date_type, task: task, person: person) : ta.update(person: person)
	end
end
#	def get_s_time
#		puts task_type.s_time
#	end

#	def get_e_time
#		puts task_type.e_time
#	end
#end
