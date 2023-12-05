###########################################################################################
# DESCRIPTION
# A class defininign the permissions of a user on a model.
###########################################################################################

#A class containing the Users data
class ModuleUser < ActiveRecord::Base

	belongs_to :user
	belongs_to :pulpo_module
	enum modulepermission: {forbidden: 0, allowed: 1}

end #class end