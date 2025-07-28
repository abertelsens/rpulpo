# schedule.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-10-05
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defining a schedule object. A schedue is just a type of day that will have
# a day schedule assigned.

#---------------------------------------------------------------------------------------

class Schedule < ActiveRecord::Base

	has_many	:task_schedules, 	dependent: :destroy
	has_many	:day_schedules, 	dependent: :destroy

	validates :name, uniqueness: { message: "ya hay otro tipo de día con ese nombre." }

	default_scope { order(name: :asc) }

	# -----------------------------------------------------------------------------------------
	# CRUD METHODS
	# -----------------------------------------------------------------------------------------

	def self.create(params)
		super(Schedule.prepare_params params)
	end

	def update(params)
		super(Schedule.prepare_params params)
	end

	def self.prepare_params(params)
	{
		name: 				params[:name],
		description: 	params[:description]
	}
	end

	# -----------------------------------------------------------------------------------------
	# ACCESSORS
	# -----------------------------------------------------------------------------------------

	def self.get_all
		Schedule.all.order(name: :asc)
	end

	def to_s
		"#{name} - #{description}"
	end


	# validates the params received from the form.
	def self.validate(params)
		ent = Schedule.new(Schedule.prepare_params params)
		{ result: ent.valid?, message: ValidationErrorsDecorator.new(ent.errors.to_hash).to_html }
	end

	# validates the params received from the form.
	def validate(params)
		self.update(params)
		{ result: valid?, message: ValidationErrorsDecorator.new(errors.to_hash).to_html }
	end


end
