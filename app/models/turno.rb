
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
		#rooms_list = rooms.order(room: :asc) unless rooms.nil?
		#return "[#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}],[-], [-]\n" if rooms_list.empty?
		#first_room = "[#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}], [#{rooms_list[0].person.short_name}], [#{rooms_list[0].room}]  \n"
		#if rooms_list.size==1
		#	first_room
		#else
	#		first_room << ",\n" << ((rooms_list[1..(rooms.size - 1)]).map{|room| "[],[#{room.person.short_name}], [#{room.room}]"}).join(",\n") unless rooms_list.size<=1
		#end
	end

end #class end

class TurnoRoom < ActiveRecord::Base

	belongs_to :room
	belongs_to :turno

end #class end
