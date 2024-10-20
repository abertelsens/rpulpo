class ModuleUser < ActiveRecord::Base

	belongs_to :user
	belongs_to :pulpomodule

	enum modulepermission: {forbidden: 0, allowed: 1}

end #class end
