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
  has_many    :days_available,  :class_name => 'DayAvailable', dependent: :destroy
  has_many    :tasks_available,  :class_name => 'TaskAvailable', dependent: :destroy


	def self.prepare_params(params)
		{
			person_id:   params["person"].to_i,
			s_date: 	Date.parse(params["s_date"]),
			e_date: 	Date.parse(params["e_date"])
    }
	end

  def self.create(params)
    pp = super(PersonPeriod.prepare_params params)
    pp.update_days_available params
    pp.update_tasks_available params
  end

  def update(params)
    super(PersonPeriod.prepare_params params)
    update_days_available params
    update_tasks_available params
  end

  def update_days_available(params)
    daAM = params["AM"].nil? ? nil : params["AM"].keys
    daPM = params["PM"].nil? ? nil : params["PM"].keys
    days_available.destroy_all

    daALL = daAM & daPM
    daAM = daAM - daALL
    daPM = daPM - daALL
    daAM = daAM.map {|day| DayAvailable.create(person_period: self, day: day.to_i, time: "AM")} unless daAM.nil?
    daPM = daPM.map {|day| DayAvailable.create(person_period: self, day: day.to_i, time: "PM")} unless daPM.nil?
    daALL = daALL.map {|day| DayAvailable.create(person_period: self, day: day.to_i, time: "ALL")} unless daALL.nil?

  end

  def update_tasks_available(params)
    tasks = params["task"].nil? ? nil : params["task"].values
    tasks_available.destroy_all
    tasks_available = tasks.map {|task| TaskAvailable.create(person_period: self, task_id: task.to_i)} unless tasks.nil?
  end

  # finds the available people for a task with a specific day_schedule. The result depends on
  # on the day of the week and the time of the task
  def self.find_people_available(day_schedule,task)
    ts = TaskSchedule.find_by(task: task, schedule: day_schedule.schedule)
    return [] if (ts.nil? || ts.number=0)
    peopleperiods = PersonPeriod.includes(:person).where(s_date: ..day_schedule.date , e_date: day_schedule.date..)
    available_periods = peopleperiods.select{|pp| pp.is_available?(day_schedule.date.wday, ts.get_time, task)}
    free_people = (available_periods.select{|ap| ap.is_free?(day_schedule, ts)}).map{|pp| pp.person}
  end

  def is_available?(wday, time, task=nil)
    # check if the person in principle is available that day
    is_availabe_on_day = !days_available.find_by(day: wday, time: [time,"ALL"]).nil?
    is_availabe_for_task = !tasks_available.find_by(task: task).nil? unless task.nil?
    task.nil? ? is_availabe_on_day : (is_availabe_on_day && is_availabe_for_task)
  end

  def is_free?(day_schedule, ts)
    # get all the task assignments for a specific day
    tas = TaskAssignment.where(person: self.person, day_schedule: day_schedule)
    return true if tas.empty?
    # if there are tasks assigned already to the person on that day, check if they fall on the same time
    (tas.select{|ta| ta.get_time==ts.get_time}).empty?
  end

  def is_available_for_task?(task)
    tasks_available.find_by(task: task)!=nil
  end

end

class DayAvailable < ActiveRecord::Base

  belongs_to  :person_period
  enum time:     {AM: 0, PM:1, ALL:2}
  self.table_name = "days_available"

  def self.prepare_params(params)
		{
			person_period:    params["person_period"],
			day: 	            params["day"],
			time:             par
    }
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
