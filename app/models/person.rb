
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
	CHECKMARK = "\u2714".encode('utf-8')
	PHOTO_DIR = "app/public/photos"

	# the related tables have a destroy dependency, i.e. if a person is deleted then also
	# the matching table entries are destroyed as well.
	has_one :crsrecord, 				dependent: :destroy, class_name: "Crsrecord"
	has_one :personal, 					dependent: :destroy
	has_one :study, 						dependent: :destroy
	has_one :matrix, 						dependent: :destroy
	has_one :permit, 						dependent: :destroy
	has_many :tasks_available, 	:through => :matrix
	has_one :room
	has_many :turnos

	# matrix associations
	has_many :task_assignments, dependent: :destroy
	has_many :person_periods, 	dependent: :destroy
	has_many :period_points, 		dependent: :destroy

	# the default scoped defines the default sort order of the query results
	default_scope { order(family_name: :asc) }
	scope :cavabianca, ->(amount) { where(ctr: "cavabianca")}
	scope :laicos, -> { where(status:"laico") }
	scope :in_rome, -> { where.not(ctr:"se_ha_ido") }

	# A scope that looks at all the people in a specific phase. Example: Person.phase("configuracional")
	scope :phase, -> (phase) { joins(:crsrecord).where(crsrecord: {phase: phase}) }

	# enums info is stored as an integer in the db but can be queried by the associated
	# enum symbol.
	enum status:    {laico: 0, diacono: 1, sacerdote: 2 }
	enum ctr:       {cavabianca: 0, ctr_dependiente:1, no_ha_llegado:2, se_ha_ido: 3   }
	enum n_agd:     {n:0, agd:1}

	# -----------------------------------------------------------------------------------------
	# CALLBACKS
	# -----------------------------------------------------------------------------------------

	before_save do
		# if the status of a person changed we also update the phase field
		crs_record.update(phase:"síntesis") if (status=="diacono" && crs)
		crs_record.update(phase:nil) if (status=="sacerdote" && crs)
		self.full_name = "#{first_name} #{family_name}"
	end

	# if a person is destroyed we also delete the associated photo of the person if it exists
	before_destroy do
		begin
			FileUtils.rm "#{PHOTO_DIR}/#{id}.jpg" if File.exist?("#{PHOTO_DIR}/#{id}.jpg")
		rescue
			puts Rainbow("PULPO: could not delete photo of #{short_name} (id: #{id})").orange
		end
	end

	# -----------------------------------------------------------------------------------------
	# CRUD METHODS
	# -----------------------------------------------------------------------------------------

	def self.create(params)
		super(Person.prepare_params params)
	end

	def update(params)
		super(Person.prepare_params params)
	end

	# delete from the hash all the parameters that do not belong to the model.
	def self.prepare_params(params)
		params.select{|param| Person.attribute_names.include? param}
	end

	#just to make sure I did not mess up the names.
	#def crs
		#self.crsrecord
	#end

	def self.associations
		@@associations
	end

	# the search method
	# @search_string: the string containing the query
	# @table_settings: the settings, i.e. information to be displayed. It is an object that
	# defines what tables should be included in the query results. This helps us to reduce
	# unnecessary information. For example if we query a person by name but the settings do
	# not include the rooms table, then we will not retrieve that result. See pulpo_query.rb
	def self.search(search_string, table_settings=nil, filter=nil)
		puts "got search_string #{search_string} filter #{filter}"
		if (filter!=nil && !filter.strip.blank?)
			search_string = (search_string.nil? || search_string.strip.blank?) ? filter : "#{filter} AND #{search_string}"
		end
		#puts Rainbow("searching for ----#{search_string}----").orange
		(PulpoQuery.new(search_string, table_settings)).execute
	end

	# retrieves an attribute value
	# @attribute_string: a string of the form "person.att_name"
	# @format: a string defining a special format. For example a date can be retrieved
	# in its latin form.
	def get_attribute(attribute_string, format=nil)
		# get the taable and attribute name
		table, attribute = attribute_string.split(".")
	 	# if the table is people then we have just to get the attribute
		# if it is a related table we first fetch the related object via the @@associations variable
		# which contains a mapping of the kind table_name => class_name
		# the send(attribute.to_sym) method calls object.method_name
		res = case table
			when "person", "people" then self[attribute.to_sym]
			else send(@@associations[table].to_sym)&.send(attribute.to_sym)
		end
		res = "" if res.nil?
		puts Rainbow("\nPULPO: Warning! found nil while looking for #{attribute_string}").orange if res.nil?
		return CHECKMARK if res==true
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

	def self.collection_to_csv(people, table_settings)
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

	@@associations = Person.reflect_on_all_associations(:has_one).map{|ass|{ass.plural_name => ass.class_name.downcase}}.reduce({}, :merge)
	puts "associations: ·#{@@associations}"
end
