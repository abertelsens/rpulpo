
# person.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# This file defines the model of a person in pulpo containing its basi information.
# Each person has also a series of related information: personal info, study, and info
# related to the crs+.
# These could have been defined in the same person table, but diving the info gives
# more flexibility to regulate access to different users
#---------------------------------------------------------------------------------------

# requiere some utilities related to the queries
require_relative '../utils/pulpo_query'

class Person < ActiveRecord::Base

	MONTHS_LATIN = [nil, "ianuarii", "februarii", "martii", "aprilis", "maii", "iunii", "iulii", "augusti", "septembris", "octobris", "novembris", "decembris"]

	# the related tables have a destroy dependency, i.e. if a person is deleted then also
	# the matching table entries are destroyed as well.
	has_one :crs, 							dependent: :destroy
	has_one :personal, 					dependent: :destroy
	has_one :study, 						dependent: :destroy
	has_one :matrix, 						dependent: :destroy
	has_many :tasks_available, 	:through => :matrix
	has_one :room
	has_many :turnos


	# matrix associations
	has_many :task_assignments, dependent: :destroy
	has_many :person_periods, 	dependent: :destroy
	has_many :period_points, 		dependent: :destroy

	# the default scoped defines the default sort order of the query results
	default_scope { order(family_name: :asc) }

	# enums info is stored as an integer in the db but can be queried by the associated
	# enum symbol.
	enum status:    {laico: 0, diacono: 1, sacerdote: 2 }
	enum ctr:       {cavabianca: 0, ctr_dependiente:1, no_ha_llegado:2, se_ha_ido:3   }
	enum n_agd:     {n:0, agd:1}
	enum vela:      {normal:0, no:1, primer_turno:2, ultimo_turno:3}


	# -----------------------------------------------------------------------------------------
	# CALLBACKS
	# -----------------------------------------------------------------------------------------

	before_save do
		full_info = "#{(title.nil? ? "" : title+" ")}#{first_name} #{family_name} #{group}"
    full_name = "#{first_name} #{family_name}"

		# if the status of a person changed we also update the phase field
		self.crs.update(phase:"síntesis") if status=="diacono"
		self.crs.update(phase:nil) if status=="sacerdote"
	end

	# if a person is destroyed we also delete the associated photo of the person if it exists
	before_destroy do
		FileUtils.rm "app/public/photos/#{id}.jpg" if File.exist?("app/public/photos/#{id}.jpg")
	end

	def self.create_from_params(params)
		Person.create Person.prepare_params params
	end

	def update_from_params(params)
		update Person.prepare_params params
	end

	# prepares the parameters received from the form to an update/create the person object.
	def self.prepare_params(params)
		params["student"] = params["student"]=="true"
		params["full_name"] = "#{params[:first_name]} #{params[:family_name]}"

		# delete from the hash the commit, id and photo_file fields before creating
		# or updating the object
		params.except("commit", "id", "photo_file")
	end

	# the search method
	# @search_string: the string containing the query
	# @table_settings: the settings, i.e. information to be displayed. It is an object that
	# defines what tables should be included in the query results. This helps us to reduce
	# unnecessary information. For example if we query a person by name but the settings do
	# not include the rooms table, then we will not retrieve that result. See pulpo_query.rb
	def self.search(search_string, table_settings=nil)
		(PulpoQuery.new(search_string, table_settings)).execute
	end

	# retrieves an attribute value
	# @attribute_string: a string of the form "person.att_name"
	# @format: a string defining a special format. For example a date can be retrieved
	# in its latin form.
	def get_attribute(attribute_string, format=nil)
		table, attribute = attribute_string.split(".")
		if attribute=="cfi"
			return Person.find(crs[:cfi]).short_name unless (crs.nil? || crs[:cfi].nil?)
			return ""
		end
		res = case table
			when "person", "people" then self[attribute.to_sym]
			when "studies"          then (study.nil? ? "" : study[attribute.to_sym])
			when "personals"        then (personal.nil? ? "" : personal[attribute.to_sym])
			when "crs"              then (crs.nil? ? "" : crs[attribute.to_sym])
			when "rooms"            then (room.nil? ? "" : room[attribute.to_sym])
		end
		res = "" if (res.nil? || res.blank?)
		puts Rainbow("\nPULPO: Warning! found nil while looking for #{attribute_string}").orange if res.nil?
		if res.is_a?(Date)
			return res.strftime("%d-%m-%y") if format.nil?
			return latin_date(res) if format=="latin"
		end
		res
	end

	def self.get_editable_attributes()
	[
		{name: "group",          value: "string",    description: "group in cavabianca"},
		{name: "ctr",            value: "options",   description: "ctr donde vive"},
		{name: "status",         value: "options",   description:  "laico/diácono/sacerdote"},
		{name: "n/agd",          value: "options",   description:  "n/agd"},
		{name: "year",           value: "string",    description:  "año en cavabianca"},
	]
	end

	def get_attributes(attributes)
			attributes.map {|att| {att => get_attribute(att)} }
	end

	def self.collection_to_csv(people,table_settings)
			result = (table_settings.att.map{|att| att.name}).join("\t") + "\n"
			result << (people.map {|person| (table_settings.att.map{|att| (person.get_attribute(att.field).dup)}).join("\t") }).join(("\n"))
	end

	def latin_date(date)
		"die #{date.day} mensis #{MONTHS_LATIN[date.month]} anni #{date.year}"
	end

	# -----------------------------------------------------------------------------------------
	# MATRIX METHODS
	# -----------------------------------------------------------------------------------------

	def self.find_people_available(day_schedule,task)

		task_schedule = TaskSchedule.find_by(task: task, schedule: day_schedule.schedule)

		periods = PersonPeriod.includes(:person).
		joins(:tasks_available).
		where(tasks_available: {task: task.id}).
		where(s_date: ..day_schedule.date, e_date: day_schedule.date..)
		#.pluck(:id, :short_name, 'person_periods.id')


		periods_available = periods.select{|pp| pp.is_free?(day_schedule, task_schedule)}
		people_available = periods_available.map{|period| {period.person_id => period.days_available.find_by(day:wday).get_situation(ts)} }
		people_with_assignments = people_with_assignments(day_schedule, task_schedule)
		people_available = people_available - people_with_assignments
		people_available.map do |pp|
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
		#periods_available =  periods.select {|period| period.is_available_for_task? task }
		#puts Person.joins(:person_periods).where(person_periods: {s_date: ..day_schedule.date, e_date: day_schedule.date..}).to_sql
		#TaskAssignment.includes(:task_schedule).joins(:day_schedule).where(day_schedule: {period: period.id}).where(person: person).sum(:points)
		#people = people.select {|person| person.period.is_available_for_task? task }
		puts people_available.inspect
		puts people_with_assignments.inspect
	end

	# get the person period that defines the availabily of a person for a given day_schedule
	def get_person_period(day_schedule)
		person_periods.find_by(s_date: ..day_schedule.date , e_date: day_schedule.date..)
	end

	def is_available_for_task?(day_schedule,task)
		get_person_period(day_schedule).is_available_for_task? task
	end

	# finds all the people that have assignmnets that clash with the given task schedule
	def self.people_with_assignments(day_schedule, task_schedule)
		tas = TaskAssignment.where(day_schedule: day_schedule).select{|ta| ta.clashes_with_task? task_schedule}.map{|ta| ta.person_id}
	end
end
