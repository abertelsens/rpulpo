###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

#A class containing the Users data
class Crs < ActiveRecord::Base

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
            classnumber:   	params[:classnumber],
            pa:    		 	params[:pa].blank? ? nil : Date.parse(params[:pa]),
            admision:    	params[:admision].blank? ? nil : Date.parse(params[:admision]),
            oblacion:     	params[:oblacion].blank? ? nil : Date.parse(params[:oblacion]),
            fidelidad:     	params[:fidelidad].blank? ? nil : Date.parse(params[:fidelidad]),
            letter:    		params[:letter].blank? ? nil : Date.parse(params[:letter]),
            admissio:       params[:admissio].blank? ? nil : Date.parse(params[:admissio]),
            presbiterado:   params[:presbiterado].blank? ? nil : Date.parse(params[:presbiterado]),
            diaconado:      params[:diaconado].blank? ? nil : Date.parse(params[:diaconado]),
            acolitado:      params[:acolitado].blank? ? nil : Date.parse(params[:acolitado]),
            lectorado:    	params[:lectorado].blank? ? nil : Date.parse(params[:lectorado]),
            cipna:        	params[:cipna]
            
        }
    end

    def can_be_deleted?
        true
    end
end