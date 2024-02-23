

class TaskAssignment < ActiveRecord::Base

	belongs_to 	:person
	belongs_to 	:task
	belongs_to 	:day_schedule #, :source => :date
	has_one 		:schedule, :through => :day_schedule
	has_one			:task_type, :through => :day_schedule, :source => :task_type

	def self.assign(task, day_schedule, people)
		ta = TaskAssignment.where(day_schedule: day_schedule, task: task)
		people.each do |person|
			if person.nil?
				ta.destroy if !ta.nil?
			else
				ta.nil? ? TaskAssignment.create(day_schedule: day_schedule, task: task, person: person) : ta.update(person: person)
			end
		end
	end

end #class end
