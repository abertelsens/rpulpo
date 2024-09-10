###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

#A class containing the Users data
class Personal < ActiveRecord::Base

	belongs_to 	:person

	def self.prepare_params(params)
    {
			params.except("personal_id", "id")
		}
  end

end # class end
