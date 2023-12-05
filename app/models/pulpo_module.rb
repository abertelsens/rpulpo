###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

#A class containing the Users data
class PulpoModule < ActiveRecord::Base

##########################################################################################
# STATIC METHODS
##########################################################################################
	
	def self.create_from_params(params)
        params.delete("commit")
		params.delete("id")
		PulpoModule.create params
	end

	def self.get_all()
		PulpoModule.order(uname: :asc)
	end


	######################################################################################################
    # CRUD METHODS
    ######################################################################################################

    def update_from_params(params)
		params.delete("commit")
		self.update params
	end

    def delete
        self.destroy
    end

end #class end