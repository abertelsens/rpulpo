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
  end

  def update(params)
    super(PersonPeriod.prepare_params params)
    update_days_available params
  end

  def update_days_available(params)
    daAM = params["AM"].nil? ? nil : params["AM"].keys
    daPM = params["PM"].nil? ? nil : params["PM"].keys
    days_available.destroy_all
    daAM = daAM.map {|day| DayAvailable.create(person_period: self, day: day.to_i, time: "AM")} unless daAM.nil?
    daPM = daPM.map {|day| DayAvailable.create(person_period: self, day: day.to_i, time: "PM")} unless daPM.nil?
  end

  # finds the available people for a task with a specific day_schedule. The result depends on
  # on the day of the week and the time of the task
  def self.find_people_available(day_schedule,task)
    ts = TaskSchedule.find_by(task: task, schedule: day_schedule.schedule)
    return [] if ts.nil?
    peopleperiods = PersonPeriod.includes(:person).where(s_date: ..day_schedule.date , e_date: day_schedule.date..)
    available_periods = peopleperiods.select{|pp| pp.is_available?(day_schedule.date.wday, ts.get_time)}
    puts "got people available"
    available_periods.each{|ap| puts ap.person.short_name}
    free_people = (available_periods.select{|ap| ap.is_free?(day_schedule, ts)}).map{|pp| pp.person}
    puts "got free"
    free_people.each{|p| puts p.short_name}
    puts "------------------"
    free_people
  end

  def is_available?(wday, time)
    # check if the person in principle is available that day
    result = !days_available.find_by(day: wday, time: time).nil?
  end

  def is_free?(day_schedule, ts)
    # get all the task assignments for a specific day
    tas = TaskAssignment.where(person: self.person, day_schedule: day_schedule)
    return true if tas.empty?
    # if there are tasks assigned already to the person on that day, check if they fall on the same time
    (tas.select{|ta| ta.get_time==ts.get_time}).empty?
  end
end

class DayAvailable < ActiveRecord::Base

  belongs_to  :person_period
  enum time:     {AM: 0, PM:1}
  self.table_name = "days_available"

  def self.prepare_params(params)
		{
			person_period:    params["person_period"],
			day: 	            params["day"],
			time:             par
    }
	end

end
