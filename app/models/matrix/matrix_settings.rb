# matrix_settings.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-09-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# This file defines the model of a persons availability for matrix tasks.
#---------------------------------------------------------------------------------------
class Matrix < ActiveRecord::Base

  belongs_to  :person
  has_many    :tasks_available,   dependent: :destroy

  # enables the creation/update of the association model_users via attributes.
	# See the the prepare_params method.
	accepts_nested_attributes_for :tasks_available, allow_destroy: true

  #---------------------------------------------------------------------------------------
  # CALLBACKS
  #---------------------------------------------------------------------------------------

  # make sure once the matrix objet is created that the person has all the periodpoints objects
  # available
  after_create :create_period_points

  #---------------------------------------------------------------------------------------
  # CRUD METHODS
  #---------------------------------------------------------------------------------------

  def self.prepare_params(params, matrix=nil)
    attributes = {
			person_id:    params["person_id"].to_i,
			choir: 	      params["choir"]!=nil,
			driver: 	    params["driver"]!=nil
    }
    # if we we are updating a person period then we update the tasks available
    attributes[:tasks_available_attributes] = Matrix.prepare_tasks_available_attributes(params,(matrix.nil? ? nil : matrix))
    attributes
	end

    def self.prepare_tasks_available_attributes(params, matrix=nil)
    # get the tasks available
    puts "got params #{params}"

    # params task could be nil if no task if selected in the form
    new_available_tasks_array = (params[:task].nil? ? [] : params[:task].values.map{|task_id| task_id.to_i})
    if matrix
      old_tasks_available = matrix.tasks_available.map{|ta| {ta.task_id => ta.id} }.inject(:merge)
      old_tasks_available_array = (old_tasks_available.nil? ? [] : old_tasks_available.keys)
      tasks_to_create = (new_available_tasks_array-old_tasks_available_array)
      destroy_attributes = (old_tasks_available_array - new_available_tasks_array).map do |task_id|
        {
          id:       old_tasks_available[task_id],
          _destroy: true
        }
      end
    else
      tasks_to_create = new_available_tasks_array
      destroy_attributes = []
    end
    create_attributes = tasks_to_create.map {|task_id| { task_id: task_id } }
    create_attributes + destroy_attributes
  end

  def self.create(params)
    pp = super(Matrix.prepare_params params)
  end

  def update(params)
    super(Matrix.prepare_params params, self)
  end

  def create_period_points
    Period.all.each{|period| PeriodPoint.create(period: period, person: person) }
  end

  def self.assign_all_tasks(period)
    tasks = Task.all.reorder(priority: :asc)
    puts "#{tasks.inspect}"
    puts "\n\n\n\n\n\n\n"
    tasks.each do |task|
      period.day_schedules.each do |day_schedule|

        # find the people available for the task
        people_available = Matrix.find_hash_for_assginments_people_available period, day_schedule, task
        if !people_available.empty?

          puts Rainbow("\n----------------------------------------------\n
          assigning people to #{task.name} on #{day_schedule.date}\n
          got hash #{people_available.inspect}
          ----------------------------------------------")
          #get the id of the first stiuation
          situation_id = people_available[0][:situation].id
          people_available = people_available.select{|hash| hash[:situation].id = situation_id }
          num = task_schedule.number - day_schedule.get_number_of_assigned_people(task)

          puts Rainbow("\n----------------------------------------------\n
          \n
          got new hash #{people_available.inspect}
          ----------------------------------------------")
          people_size = people_available.size
          task_schedule = TaskSchedule.find_by(task: task, schedule: day_schedule.schedule)
          num = task_schedule.number - day_schedule.get_number_of_assigned_people(task)
          index = 0
          while (index < num && people_size>0)
            person_index = rand(0..people_size-1)
            TaskAssignment.create(day_schedule: day_schedule, task_schedule: task_schedule, person_id: people_available[person_index][:person_id])
            index = index +1
            people_available = people_available - [people_available[person_index]]
            people_size = people_available.size
          end
        end
      end
    end
  end

  def self.find_hash_for_assginments_people_available(period,day_schedule,task)

    task_schedule = TaskSchedule.find_by(task: task, schedule: day_schedule.schedule)
    assigned_people_ids = (day_schedule.get_assigned_people task).pluck(:id)

    # the people in the hash includes those already assigned to the task
    people_available = Matrix.find_people_available(period,day_schedule,task)

    hash = people_available.map do |person|
      ppoints = person.period_points.first
      points = ppoints.nil? ? 0 : ppoints.points
      {
        person_id:      person.id,
        name:           person.short_name,
        situation:      person.person_periods.first.days_available.first.get_situation(task_schedule),
        points:         points
      }
    end

    hash = hash.sort_by { |person_hash| person_hash[:points] }
    hash = hash.sort_by { |person_hash| person_hash[:situation][:points] }

  end


  def self.find_hash_people_available(period,day_schedule,task)

    task_schedule = TaskSchedule.find_by(task: task, schedule: day_schedule.schedule)
    assigned_people_ids = (day_schedule.get_assigned_people task).pluck(:id)

    # the people in the hash includes those already assigned to the task
    people_available = Matrix.find_people_available(period,day_schedule,task).or(Person.where(id: assigned_people_ids))

    hash = people_available.map do |person|
      ppoints = person.period_points.first
      points = ppoints.nil? ? 0 : ppoints.points
      {
        person_id:      person.id,
        available:      true,
        name:           person.short_name,
        situation:      person.person_periods.first.days_available.first.get_situation(task_schedule),
        points:         points
      }
    end

    hash = hash.sort_by { |person_hash| person_hash[:points] }
    hash = hash.sort_by { |person_hash| person_hash[:situation][:points] }

  end

  def self.find_people_available(period,day_schedule,task)

    # find the task schedule corresponding to the task on the day specified by the day schedule.
    task_schedule = TaskSchedule.find_by(task: task, schedule: day_schedule.schedule)
    wday = day_schedule.date.wday

    people_who_can_do_task_ids = TasksAvailable.includes(:matrix, :person).where(task: task).pluck('people.id')

    # get all the perids of people that correpond to the date we are examining
    periods = PersonPeriod.includes(:person).where(s_date: ..day_schedule.date, e_date: day_schedule.date..)
    # select only the people that are free (have no tasks assigned at that time)
    periods = periods.select{|pp| pp.is_free?(day_schedule,task_schedule)}

    people_available = Person
      .includes(:period_points, person_periods: [:days_available])
      .joins(:period_points, person_periods: [:days_available])
      .where(
        "people.id" => periods.pluck(:person_id),
        "days_available.day" => wday,
        "id" => people_who_can_do_task_ids,
        "period_points.period_id" => period.id
        )
  end

end #class end



class TasksAvailable < ActiveRecord::Base

  belongs_to  :matrix
  has_one     :person, :through => :matrix
  belongs_to  :task
  self.table_name = "tasks_available"

end

class AssignmentCandidate

  def initialize(person_id, situation, points)
    @person_id = persson_id
    @situation = situation
    @points = points
  end

end

def AssignmentCandidates

end
