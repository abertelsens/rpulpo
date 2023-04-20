###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

#A class containing the Users data
class Study < ActiveRecord::Base

	belongs_to 	:person
	#has_many 	:transactions

	#validates   :department, 	presence: true
    
    ##########################################################################################
	# CALLBACKS
	##########################################################################################
	
	# after a transaciton is saved we make sure to update the balance in the related report
	# Chashbox overrides this method.
	def self.prepare_params(params)
        {
			civil_studies: 			params[:civil_studies],
			studies_name: 			params[:studies_name],
			degree: 				params[:degree],
			profesional_experience: params[:profesional_experience],
			year_of_studies: 		params[:year_of_studies],
			faculty: 				params[:faculty],
			status: 				params[:study_status],
			licence: 				params[:licence],
			doctorate: 				params[:doctorate],
			thesis: 				params[:thesis],
			
		}
    end

    def can_be_deleted?
        true
    end
end