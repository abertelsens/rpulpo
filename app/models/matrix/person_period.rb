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
  has_many    :days_available,    :class_name => 'DayAvailable', dependent: :destroy
  has_many    :tasks_available,   :class_name => 'TaskAvailable', dependent: :destroy

  def self.prepare_params(params)
		{
			person_id:   params["person"].to_i,
			s_date: 	Date.parse(params["s_date"]),
			e_date: 	Date.parse(params["e_date"])
    }
	end

  def self.create(params)
    pp = super(PersonPeriod.prepare_params params)
    #pp.update_days_available params
    pp.update_tasks_available params
  end

  def update(params)
    super(PersonPeriod.prepare_params params)
    update_days_available params
    update_tasks_available params
  end

  def update_days_available(params)
    daAM = params["AM"]
    daPM1 = params["PM1"]
    daPM2 = params["PM2"]
    days_available.destroy_all
    days_available = daAM.keys.each {|key| DayAvailable.create(person_period: self, day: key.to_i, AM: daAM[key], PM1: daPM1[key], PM2: daPM2[key] )}

  end

  def update_tasks_available(params)
    tasks = params["task"].nil? ? nil : params["task"].values
    tasks_params = tasks.map {|task| { person_period: self, task_id: task.to_i} } unless tasks.nil?
    tasks_available.destroy_all
    tasks_available = TaskAvailable.create(tasks_params)
  end

  # finds the available people for a task with a specific day_schedule. The result depends on
  # on the day of the week and the time of the task
  def self.find_people_available(day_schedule, task)
    ts = TaskSchedule.find_by(task: task, schedule: day_schedule.schedule)
    puts "finding people available. Found ts #{ts}. #{ts.number} people needed"
    return [] if (ts.nil? || ts.number==0)
    people_periods = PersonPeriod.includes(:person).where(s_date: ..day_schedule.date , e_date: day_schedule.date..)
    puts "found available people perdiods. Found#{peopleperiods}"
    available_periods = people_periods.map{|pp| pp.person.id => pp.get_availability(wday,ts) }
    free_people = (available_periods.select{|ap| ap.is_free?(day_schedule, ts)}).map{|pp| pp.person}
    period = day_schedule.period
    free_people
  end

  def get_availability(wday,task_schedule)
    day = days_available.find_by(day: wday) if !wday.nil?
    day.get_value task_schedule
  end

  def get_availability(week_day, task_schedule)
      # if the task is not one of the tasks the person does return false.
      return false if is_available_for_task? task_schedule.task
      self.get_value
      is_available_on_day?(week_day, task_schedule)

  end

  def is_free?(day_schedule, ts)
    # get all the task assignments for a specific day
    puts "\n\n\n\n\n------------------checking if #{person.short_name} is free on ts:"
    puts ts.inspect
    puts "checking if #{person.short_name} is free on ts----------------------"
    tas = TaskAssignment.where(person: self.person, day_schedule: day_schedule)
    puts "------------------checking task assignmens of #{person.short_name}"
    puts tas.inspect
    puts "----------------------"
    return true if tas.empty?
    # if there are tasks assigned already to the person on that day, check if they fall on the same time
    (tas.select{|ta| ta.get_time==ts.get_time}).empty?
  end

  def is_available_for_task?(task)
    tasks_available.find_by(task: task)!=nil
  end

  def is_available_on_day?(wday, task_schedule)
    da = days_available.find_by(wday: wday)!=nil
    da.AM1
  end

  #def calculate_assignments_time(period)
  #  tas = TaskAssignment.where(person: self.person, day_schedule: day_schedule)
  #end

end

class DayAvailable < ActiveRecord::Base

  belongs_to  :person_period
  self.table_name = "days_available"

  AM_PM1 = (7.0..14)
  PM1_PM2 = (14..17.5)
  AFTER_PM2 = (17.5..22)
  TIME_SLOTS = [AM_PM1, PM1_PM2, after_PM2]

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
  def get_value(task_schedule)
    situations = Situation.all
    task_range = (task_schedule.s_time..task_schedule)
    overlapping_time_slots = TIME_SLOTS.map.with_index do |ts, index|
       (ts.overlap? task_range) ? index_to_time_slot(index) : ""
    end
    max_value = (overlapping_time_slots.map {|ts| self[ts]}).max
    max_time_slot = overlapping_time_slots.select {|ts| self[ts]== max_value}
  end

  def index_to_time_slot(index)
    case index
    when 0 then "AM"
    when 1 then "PM1"
    when 2 then "PM2"
  end
end

  class TaskAvailable < ActiveRecord::Base

    belongs_to  :person_period
    belongs_to  :task
    self.table_name = "tasks_available"

    def self.prepare_params(params)
    {
      person_period:    params["person_period"],
      task: 	          params["task"]
    }
    end


  end
