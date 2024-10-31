
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

	# the default scoped defines the default sort order of the query results
	default_scope { order(name: :asc) }

# -----------------------------------------------------------------------------------------
# CALLBACKS
# -----------------------------------------------------------------------------------------

# after a module is created we also create permissions to all users. Bu default all users
# will be forbidden to access the moudule.
after_save do
	puts "creating permissions for new module"
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

	# Validates the parameters from the modules form.
	# Checks whether there is already a user with the provided user name
	def self.validate(params)
		warning_message = "Warning: there is already a module with that name."
		identifier = params[:identifier].strip
		found =
			if (params[:id])=="new"
				!PulpoModule.find_by(identifier: identifier).nil?
			else
				pmodule = PulpoModule.find_by(identifier: identifier)
				pmodule.nil? ? false : (pmodule.id!=params[:id].to_i)
			end
		found ? {result: false, message: warning_message} : {result: true}
	end

end #class end
