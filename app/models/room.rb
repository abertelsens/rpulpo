
# room.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2025-01-13
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defining a room.
#---------------------------------------------------------------------------------------

class Room < ActiveRecord::Base


	@@gsheet_update_request = nil

	# a room belongs to a person but the association can be nil if the room is empty.
	belongs_to 	    :person

	scope :in_use, 	-> { includes(:person).where.not(person_id: nil) }
	scope :free, 		-> { includes(:person).where(person_id: nil) }

	enum :house,    {
										dirección: 0,
										profesores: 1,
										pabellón: 2,
										sala_de_conferencias: 3,
										altana: 4,
										chiocciola: 5,
										mulino: 6,
										borgo: 7,
										ospiti: 8,
										enfermería: 9,
										casa_del_consejo: 10
									}

	enum :bed,       {normal: 0, larga: 1, reclinable: 2}
	enum :bathroom,  {individual: 0, común: 1}

	# after updating a room we also update the information in the gsheets that the ao has.
	after_save      :update_gsheet_async

	def self.create_from_params(params)
		Room.create Room.prepare_params params
	end

	def update_from_params(params)
		update Room.prepare_params params
	end

	def self.prepare_params(params)
		params[:person_id] = nil if params[:person_id].blank?
		params.except "commit", "id"
	end

	def self.search(search_string, table_settings=nil)
		PulpoQuery.new(search_string, table_settings).execute
	end

	# returns a hash with the informations about total and empty rooms for each house
	def self.get_rooms_count_by_house()
		empty = Room.free.group(:house).count
		total = Room.group(:house).order(house: :asc).count
		total.keys.map {|key| { room: key.to_s, total: total[key], empty: (empty[key].nil? ? "-" :  empty[key]) } }
	end

	# gets the rooms of the specified houses orderedby house and then by room name
	def self.get_from_houses(houses)
		Room.in_use.where(house: houses).in_order_of(:house, houses).order(room: :asc)
	end

	# --------------------------------------------------------------------------------------------------------------------
	# GSHEETS
	# --------------------------------------------------------------------------------------------------------------------
	# updates the google sheets with the info of the roooms
	def update_gsheet
		if Time.now - @@update_request > 5
			is_guest 					= proc {|room| room.person&.ctr=="guest" }
			attributes =  		%w(person.clothes house room person.status) << is_guest << "person.notes_ao_room"
			decorator = ARDecorator.new(Room.in_use.order('people.clothes'), :boolean_checkmark)
			values = decorator.get_attribute attributes
			GSheets.new(:rooms_by_clothes).update_sheet values

			attributes =  		%w(house room person.clothes person.status) << is_guest << "person.notes_ao_room"
			decorator = ARDecorator.new(Room.in_use.order(:house, :room), :boolean_checkmark)
			values = decorator.get_attribute attributes
			GSheets.new(:rooms_by_house).update_sheet values
			@gsheet_update_request = nil
		else
			sleep 5
			update_gsheet
		end
	end

	# creates ta new thread used to update the google sheets asynchronously. Thus pulpo needs not to wait till the
	# request to gsheets is completed.
	# the thread is created only if there is no other thread running.
	def update_gsheet_async
		return unless @@gsheet_update_request.nil?
		@@gsheet_update_request = Time.now
		Thread.new { update_gsheet }
	end

end     #class end
