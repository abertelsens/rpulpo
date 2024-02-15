###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

#A class containing the Users data
class Personal < ActiveRecord::Base

	belongs_to 	:person
    
	def self.prepare_params(params)
    {
			person_id: 			params[:person_id],
			region_of_origin: 	params[:region_of_origin],
			region: 			params[:region],
			city: 				params[:city],
			languages: 			params[:languages],
			father_name: 		params[:father_name],
			mother_name: 		params[:mother_name],
			parents_address: 	params[:parents_address],
			parents_work: 		params[:parents_work],
			parents_info: 		params[:parents_info],
			siblings_info: 		params[:siblings_info],
			economic_info:		params[:economic_info],
			medical_info:		params[:medical_info],
			notes:				params[:notes]
		}
  end

end # class end