# Google calendar API key AIzaSyA-3PoZaonvgyax2wkRPVGsze0O7ZKJL1A


# person_period.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-09-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# This file defines the model of a persons availability during a period, typically a semester.
# It has a related table of days availabe.
#---------------------------------------------------------------------------------------

# requiere some utilities related to the queries

class PersonPeriod < ActiveRecord::Base

  belongs_to  :person
  has_many    :tasks_available,   dependent: :destroy
  has_many    :days_available,    :class_name => 'DayAvailable',  dependent: :destroy


  # enables the creation/update of the association model_users via attributes.
	# See the the prepare_params method.
	accepts_nested_attributes_for :tasks_available, allow_destroy: true
  accepts_nested_attributes_for :days_available


  #---------------------------------------------------------------------------------------
  # CRUD METHODS
  #---------------------------------------------------------------------------------------

  def self.prepare_params(params, pp=nil)
    attributes = {
			person_id:    params["person"].to_i,
			s_date: 	    Date.parse(params["s_date"]),
			e_date: 	    Date.parse(params["e_date"])
    }
    # if we we ara updating a person period then we update the tasks available
    attributes[:tasks_available_attributes] = PersonPeriod.prepare_tasks_available_attributes(params,(pp.nil? ? nil : pp))
    attributes[:days_available_attributes]  = PersonPeriod.prepare_days_available_attributes(params,(pp.nil? ? nil : pp))
    attributes
	end

  def self.prepare_days_available_attributes(params, pp=nil)
    old_days_available = pp.days_available.map{|da| {da.day => da.id} }.inject(:merge) if pp
    days_available_attributes = params["AM"].keys.map do |key|
      hash = {
        day: key.to_i,
        AM: params["AM"][key],
        PM1: params["PM1"][key],
        PM2: params["PM2"][key]
      }
      hash[:id] = old_days_available[key.to_i] if pp
      hash
    end
  end

  def self.prepare_tasks_available_attributes(params, pp=nil)
    # get the tasks available
    new_available_tasks_array = params[:task].values.map{|task_id| task_id.to_i}
    if pp
      old_tasks_available = pp.tasks_available.map{|ta| {ta.task_id => ta.id} }.inject(:merge)
      old_tasks_available_array = old_tasks_available.keys
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
    pp = super(PersonPeriod.prepare_params params)
  end

  def update(params)
    super(PersonPeriod.prepare_params params, self)
  end

  #---------------------------------------------------------------------------------------
  # ACCESSORS
  #---------------------------------------------------------------------------------------

  # finds the available people for a task with a specific day_schedule. The result depends on
  # on the day of the week and the time of the task
  def self.find_people_available(period, day_schedule, task)
    ts = TaskSchedule.find_by(task: task, schedule: day_schedule.schedule)
    wday = day_schedule.date.wday
    return [] if (ts.nil? || ts.number==0)
    # find all the people periods that are relevant to this day schedule

    people_periods = PersonPeriod.includes(:person).where(s_date: ..day_schedule.date , e_date: day_schedule.date..)

    # select only the people that are available to do the specific task
    people_periods = people_periods.select{|pp| pp.is_available_for_task? task}

    # select only the people that are free (have no tasks assigned at that time)
    people_periods = people_periods.select{|pp| pp.is_free?(day_schedule,ts)}

    # add the people already assigned for the specific task
    assigned_people_ids = (day_schedule.get_assigned_people task).pluck(:id)
    assigned_people_periods = PersonPeriod.includes(:person).where(person: assigned_people_ids)
    people_periods = people_periods.concat(assigned_people_periods)

    people_available = people_periods.map do |pp|
      ppoints = PeriodPoint.find_by(person: pp.person, period: period)
      points = ppoints.nil? ? 0 : ppoints.points
      {
        person_id:      pp.person.id,
        available:      (pp.is_available_for_task? task),
        name:           pp.person.short_name,
        situation:      pp.days_available.find_by(day:wday).get_situation(ts),
        points:         points
      }
    end
    people_available = people_available.sort_by { |person_hash| person_hash[:points] }
    people_available = people_available.sort_by { |person_hash| person_hash[:situation][:points] }

    puts "\n\n\n\n"
    puts "returning people available"
    puts people_available.inspect
    puts "\n\n\n\n"
    people_available
  end


  def get_availability(wday, task_schedule)
    return false if !(tasks_available.pluck(:task).include? task_schedule.task.id)
    return true
  end

  def get_availability(week_day, task_schedule)
      # if the task is not one of the tasks the person does return false.
      return false if is_available_for_task? task_schedule.task
      self.get_value
      is_available_on_day?(week_day, task_schedule)

  end

  def is_free?(day_schedule,task_schedule)
    tas = TaskAssignment.where(person: self.person, day_schedule: day_schedule)
    (tas.select{|ta| ta.clashes_with_task? task_schedule}).empty?
  end

  def is_available_for_task?(task)
    tasks_available.find_by(task: task)!=nil
  end

  def is_available_on_day?(wday, task_schedule)
    da = days_available.find_by(wday: wday)!=nil
    da.AM1
  end

end

class DayAvailable < ActiveRecord::Base

  belongs_to  :person_period
  self.table_name = "days_available"

  RANGES =[ (7.0..14), (14..17.5), (17.5..22) ]

  def self.prepare_params(params)
		{
			person_period:    params["person_period"],
			day: 	            params["day"],
			AM:               params["AM"],
      PM1:              params["PM1"],
      PM2:              params["PM2"],
    }
	end


  # gets the situation with the highest priority for the time schedule
  def get_situation(task_schedule)
    task_range = (task_schedule.s_time.hour..task_schedule.e_time.hour)
    am  =  Situation.find(self.AM) if task_range.overlap? (7.0..14)
    pm1 =  Situation.find(self.PM1) if task_range.overlap? (14..17.5)
    pm2 =  Situation.find(self.PM2) if task_range.overlap? (17.5..22)
    situations = [am,pm1,pm2].select{|sit| sit!=nil}
    return situations.max_by {|e| e.points }
  end

  def index_to_time_slot(index)
    case index
      when 0 then "AM"
      when 1 then "PM1"
      when 2 then "PM2"
    end
  end

end # class end

class TasksAvailable < ActiveRecord::Base

  belongs_to  :person_period
  belongs_to  :task
  self.table_name = "tasks_available"

end
