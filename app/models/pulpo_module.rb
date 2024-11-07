# pulpo_module.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defining a Module. As module is a reserved word in ruby we chose to name it
# pulpo_module
# -----------------------------------------------------------------------------------------

#A class containing the Users data
class PulpoModule < ActiveRecord::Base

	has_many 	:module_users, dependent: :destroy
	has_many	:documents

	validates :identifier, uniqueness: { message: "there is already another module with that identifier." }

	# the default scoped defines the default sort order of the query results
	default_scope { order(name: :asc) }
	scope :allowed, ->(user) { joins(:module_users).where(module_users: {user_id: user.id}) }

# -----------------------------------------------------------------------------------------
# CALLBACKS
# -----------------------------------------------------------------------------------------


# -----------------------------------------------------------------------------------------
# CRUD METHODS
# -----------------------------------------------------------------------------------------

	def self.create(params)
		super(PulpoModule.prepare_params params)
	end

	def update(params)
		super(PulpoModule.prepare_params params)
	end

	def self.destroy(params)
		PulpoModule.find(params[:id]).destroy
	end

	def self.prepare_params(params)
		params.except!("id") if params["id"]=="new"
		params.select{|param| PulpoModule.attribute_names.include? param}
	end

	def can_be_deleted?
		true
	end

# -----------------------------------------------------------------------------------------
# VALIDATIONS
# -----------------------------------------------------------------------------------------

	# validates the params received from the form.
	def self.validate(params)
		pm = PulpoModule.new(PulpoModule.prepare_params params)
		{ result: pm.valid?, message: ValidationErrorsDecorator.new(pm.errors.to_hash).to_html }
	end

	# validates the params received from the form.
	def validate(params)
		self.update(params)
		{ result: valid?, message: ValidationErrorsDecorator.new(errors.to_hash).to_html }
	end

end
