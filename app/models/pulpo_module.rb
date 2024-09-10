
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

	# the default scoped defines the default sort order of the query results
	default_scope { order(name: :asc) }

# -----------------------------------------------------------------------------------------
# CRUD METHODS
# -----------------------------------------------------------------------------------------

	def self.create(params)
		super(PulpoModule.prepare_params params)
	end

	def update(params)
		super(PulpoModule.prepare_params params)
	end

	def self.create_update(params)
		params[:id]=="new" ? PulpoModule.create(params) : PulpoModule.find(params[:id]).update(params)
	end

	def self.destroy(params)
		PulpoModule.find(params[:id]).destroy
	end

	def self.prepare_params(params)
		params.except("commit", "id")
	end

# -----------------------------------------------------------------------------------------
# VALIDATIONS
# -----------------------------------------------------------------------------------------

	# Validates the parameters from the user form.
	# Checks whether there is already a user with the provided user name
	def self.validate(params)

		# tries to find an existing module with the name provided.
		pmodule  = PulpoModule.find_by(identifier: params[:identifier])

		validation_result = pmodule.nil? ? true : pmodule.id==params[:id].to_i
		validation_result ? {result: true} : {result: false, message: "module name already in use"}
	end

end #class end
