
# turno.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-24
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION
# -----------------------------------------------------------------------------------------

class Turno < ActiveRecord::Base

	has_many 		:turno_rooms, 				dependent: :destroy
	has_many 		:rooms, 							:through => :turno_rooms
	belongs_to 	:vela

	def toTypstTable()
		turno_decorator = TurnoDecorator.new(self)
		turno_decorator.toTypstTable
	end

end #class end

class TurnoRoom < ActiveRecord::Base

	belongs_to :room
	belongs_to :turno

end #class end
