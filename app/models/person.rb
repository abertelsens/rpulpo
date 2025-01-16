
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

	PHOTO_DIR = "app/public/photos"
	DEFAULT_PERSON_IMG = "app/public/img/avatar.jpg"

	# -----------------------------------------------------------------------------------------
	# ASSOCIATIONS
	# -----------------------------------------------------------------------------------------

	# the related tables have a destroy dependency, i.e. if a person is deleted then also
	# the matching table entries are destroyed as well.
	has_one :crs_record, 				dependent: :destroy, class_name: "CrsRecord"
	has_one :personal, 					dependent: :destroy
	has_one :study, 						dependent: :destroy
	has_one :matrix, 						dependent: :destroy
	has_one :permit, 						dependent: :destroy
	has_one :room

	has_many :tasks_available, 	:through => :matrix
	has_many :turnos

	# matrix associations
	has_many :task_assignments, dependent: :destroy
	has_many :person_periods, 	dependent: :destroy
	has_many :period_points, 		dependent: :destroy

	# -----------------------------------------------------------------------------------------
	# VALIDATIONS
	# -----------------------------------------------------------------------------------------

	validates :short_name, uniqueness: { message: "there is already another person with that name." }

	# -----------------------------------------------------------------------------------------
	# SCOPES
	# -----------------------------------------------------------------------------------------

	# the default scoped defines the default sort order of the query results
	default_scope { order(family_name: :asc) }

	scope :cavabianca, 	-> (amount) { where(ctr: "cavabianca")}
	scope :laicos, 			-> { where(status:"laico") }
	scope :in_rome, 		-> { where.not(ctr:"se_ha_ido") }
	scope :students, 		-> { where(student: true) }

	# A scope that looks at all the people in a specific phase. Example: Person.phase("configuracional")
	scope :phase, 			-> (phase) { joins(:crs_record).where(crs_record: {phase: phase}) }


	# -----------------------------------------------------------------------------------------
	# ENUMS
	# -----------------------------------------------------------------------------------------

	# enums info is stored as an integer in the db but can be queried by the associated
	# enum symbol.
	enum :status,    			{ laico: 0, diacono: 1, sacerdote: 2, ordenando: 3 }
	enum :ctr,       			{ cavabianca: 0, ctr_dependiente:1, no_ha_llegado:2, se_ha_ido: 3, guest: 4 }
	enum :n_agd,     			{ n: 0, agd: 1 }
	enum :dinning_room,   { arriba: 0, abajo: 1 }

	# -----------------------------------------------------------------------------------------
	# CALLBACKS
	# -----------------------------------------------------------------------------------------

	after_create do |person|
		puts "copying picutre"
		FileUtils.cp_r(DEFAULT_PERSON_IMG, "#{PHOTO_DIR}/#{person.id}.jpg", remove_destination: false)
	end

	before_save do
		# if the status of a person changed we also update the phase field
		crs_record.update(phase:"sintesis") if (status=="diacono" && crs_record)
		crs_record.update(phase:nil) if (status=="sacerdote" && crs_record)
		self.full_name = "#{first_name} #{family_name}"

		# update the sheets of the ao if the notes or the clothes number were changed
		self.room.update_gsheet_async if (self.notes_ao_room_changed? || self.clothes_changed?) && !self.room.nil?
		if (self.celebration_changed? || self.dinning_room_changed? || self.meal_changed? || self.notes_ao_meal_changed?)
			self.update_gsheet_async
		end
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
		super(Person.prepare_params (params.except("id")))
	end

	def update(params)
		puts "updating with params #{params}"
		puts "updating with prepare params #{Person.prepare_params params}"
		puts "attributes #{Person.attribute_names}"
		super(Person.prepare_params params)
	end

	# delete from the hash all the parameters that do not belong to the model.
	def self.prepare_params(params)
		params.select{|param| Person.attribute_names.include? param}
	end


	# the search method
	# @search_string: the string containing the query
	# @table_settings: the settings, i.e. information to be displayed. It is an object that
	# defines what tables should be included in the query results. This helps us to reduce
	# unnecessary information. For example if we query a person by name but the settings do
	# not include the rooms table, then we will not retrieve that result. See pulpo_query.rb
	def self.search(search_string, table_settings=nil, filter=nil)
		#puts "got search_string #{search_string} filter #{filter}"
		if (filter && !filter.strip.blank?)
			search_string = (search_string.nil? || search_string.strip.blank?) ? filter : "#{filter} AND #{search_string}"
		end
		(PulpoQuery.new(search_string, table_settings)).execute
	end

	def update_celebration
    return if self.celebration.nil?
		today = Date.today
		if self.celebration.month == 2 && self.celebration.day == 29
			cel = Date.new(self.celebration.year,2,28)
		else
			cel = self.celebration
		end
		next_celebration_year = today.year + (today >= Date.new(today.year, cel.month, cel.day) ? 1 : 0)
		next_celebration_date = Date.new(next_celebration_year, cel.month, cel.day)
    self.celebration = next_celebration_date
    save
	end

	def self.start_update_celebration_thread
		puts Rainbow("PULPO: starting update_celebration_thread").yellow
		Thread.new do
			puts Rainbow("PULPO: sleeping for 10 seconds to wait for app to fully load").yellow
			sleep 10
			loop do
				Person.all.each(&:update_celebration)
				puts Rainbow("PULPO: sleeping for 12 hours...").yellow
				sleep 12 * 60 * 60 # Sleep for 12 hours
			end
		end
	end


	# --------------------------------------------------------------------------------------------------------------------
	# GSHEETS
	# --------------------------------------------------------------------------------------------------------------------
	# updates the google sheets with the info of the roooms
	def update_gsheet

		settings = TableSettings.new(
			name:						"celebrations_ao",
			main_table: 		"people",
			attributes:  		%w(celebration dinning_room meal notes_ao_meal).map{ |att| TableSettings.get_attribute_by_name(att) }
		)

		gsheet = GSheets.new(:celebrations)
		gsheet.update_sheet settings, Person.cavabianca , PersonDecorator.new(table_settings: settings)

	end

	# creates ta new thread used to update the google sheets asynchronously. Thus pulpo needs not to wait till the
	# request to gsheets is completed..
	def update_gsheet_async
    Thread.new { update_gsheet }
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


	# -----------------------------------------------------------------------------------------
	# VALIDATIONS
	# -----------------------------------------------------------------------------------------

	# validates the params received from the form.
	def self.validate(params)
		person = Person.new(Person.prepare_params params)
		{ result: person.valid?, message: ValidationErrorsDecorator.new(person.errors.to_hash).to_html }
	end

	# validates the params received from the form.
	def validate(params)
		self.update(params)
		{ result: self.valid?, message: ValidationErrorsDecorator.new(self.errors.to_hash).to_html }
	end

	# -----------------------------------------------------------------------------------------
	# ACTIONS
	# -----------------------------------------------------------------------------------------

	def add_year
		if self.year!=nil
			begin
				self.year = (self.year.to_i+1).to_s unless self.year.nil?
				self.save
			rescue
				puts Rainbow("PULPO: could not add year of #{self.short_name}. #{self.year} is not an integer.}").orange
			end
		end
	end


end #class end
