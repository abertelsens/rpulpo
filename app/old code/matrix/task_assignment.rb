

class TaskAssignment < ActiveRecord::Base

	belongs_to 	:person
	belongs_to 	:task_schedule
	belongs_to 	:day_schedule #, :source => :date
	has_one 		:schedule, 	:through => :day_schedule
	has_one			:task_type, :through => :day_schedule, :source => :task_type
	has_one			:task, 			:through => :task_schedule

	after_destroy do |ta|
		PeriodPoint.find_by(person: person, period: day_schedule.period).update_points
	end

	after_create do |ta|
		PeriodPoint.find_by(person: person, period: day_schedule.period).update_points
	end

	def self.assign(task_schedule, day_schedule, people)
		ta = TaskAssignment.where(day_schedule: day_schedule, task_schedule: task_schedule)
		people.each do |person|
			ta.nil? ? (ta=TaskAssignment.create(day_schedule: day_schedule, task_schedule: task_schedule, person: person)) : ta.update(person: person)
			PeriodPoint.find_by(person: person, period: day_schedule.period).update_points
		end
	end

	def get_assignments(day_schedule,task)
		day_schedule.task_assignments.where(task_schedule: {task_id: task.id})
		#task_assignments.includes(:person).joins(:task_schedule).where(task_schedule: {task_id: task.id})
	end

	def get_time
		puts "getting time of assignment: #{self.inspect}"

		time = task_schedule.get_time
		puts "got time of task assignment: #{time}"
		time
	end

	def get_assignment_time
		ts = get_task_schedule
		((ts.e_time - ts.s_time) / 1.hour).round
	end

	def get_assignment_points
		ts = get_task_schedule.points
	end

	def self.get_assignments_of_person(person, period)
		TaskAssignment.where(person: person).and
	end

	def clashes_with_task?(task_schedule)
		self.task_schedule.overlaps? task_schedule
	end

end #class end
