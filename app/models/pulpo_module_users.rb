class ModuleUser < ActiveRecord::Base

	belongs_to :user
	belongs_to :pulpo_module

	enum modulepermission: {forbidden: 0, allowed: 1}

end #class end
