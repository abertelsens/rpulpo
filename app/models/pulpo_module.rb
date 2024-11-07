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
	validates :identifier, uniqueness: { message: "there is another module with that identifier." }

	# the default scoped defines the default sort order of the query results
	default_scope { order(name: :asc) }
	scope :allowed, ->(user) { joins(:module_users).where(module_users: {modulepermission: "allowed"}) }

# -----------------------------------------------------------------------------------------
# CALLBACKS
# -----------------------------------------------------------------------------------------

# after a module is created we also create permissions to all users. Bu default all users
# will be forbidden to access the moudule.
after_save do
	ModuleUser.create(User.all.map{|user| {user: user, pulpo_module: self , modulepermission: "forbidden"} })
end

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
		params.except("commit", "id")
	end

	def can_be_deleted?
		true
	end

# -----------------------------------------------------------------------------------------
# VALIDATIONS
# -----------------------------------------------------------------------------------------

		# validates the params received from the form.
	def self.validate(params)
		mod = PulpoModule.new(params)
		{ result: mod.valid?, message: ValidationErrorsDecorator.new(mod.errors.to_hash).to_html }
	end

end #class end
