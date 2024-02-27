# -----------------------------------------------------------------------------------------
# DESCRIPTION
# A class defininign a Module .
# -----------------------------------------------------------------------------------------

#A class containing the Users data
class PulpoModule < ActiveRecord::Base

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

	def self.create_update(params)
		params[:id]=="new" ? PulpoModule.create(params) : PulpoModule.find(params[:id]).update(params)
	end

	def self.destroy(params)
		PulpoModule.find(params[:id]).destroy
	end

	def self.prepare_params(params)
		{
			name: 				params[:name],
			identifier: 	params[:identifier],
			description:	params[:description]
		}
	end

# -----------------------------------------------------------------------------------------
# ACCESSORS
# -----------------------------------------------------------------------------------------

	def self.get_all()
		PulpoModule.order(name: :asc)
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
