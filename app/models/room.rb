
# room.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defining a room.
#---------------------------------------------------------------------------------------

class Room < ActiveRecord::Base

	belongs_to 	    :person

	enum :house,     {dirección: 0, profesores: 1, pabellón: 2, sala_de_conferencias: 3, altana: 4, chiocciola: 5, mulino: 6, borgo:7, ospiti:8, enfermería: 9, casa_del_consejo: 10}
	enum :bed,       {normal: 0, larga: 1, reclinable: 2}
	enum :bathroom,  {individual: 0, común: 1}

	def self.create_from_params(params)
		Room.create Room.prepare_params params
	end

	def update_from_params(params)
		update Room.prepare_params params
	end

	def self.prepare_params(params)
		params[:person_id] = nil if params[:person_id].blank?
		params.except("commit", "id")
	end

	def self.search(search_string, table_settings=nil)
		PulpoQuery.new(search_string, table_settings).execute
	end

	# returns a has with the informations about total and empty rooms for each house
	def self.get_rooms_count_by_house()
		empty = Room.group(:house).where(person_id:nil).count
		total = Room.group(:house).order(house: :asc).count
		total.keys.map {|key| { "room" => key.to_s, "total" => total[key], "empty" => (empty[key].nil? ? "-" :  empty[key]) } }
	end

	# retrieves an attribute of the form "person.att_name"
	def get_attribute(attribute_string)
		table, attribute = attribute_string.split(".")
		res = case table
			when "rooms"     				then self[attribute.to_sym]
			when "person", "people" then person.nil? ? "-" : person[attribute.to_sym]
		end
		res = "-" if (res.nil? || res.blank?)
		res.is_a?(Date) ? res.strftime("%d-%m-%y") : res
	end

	def self.collection_to_csv(rooms,table_settings)
		result = (table_settings.att.map{|att| att.name}).join("\t") + "\n"
		result << (rooms.map {|room| (table_settings.att.map{|att| (room.get_attribute(att.field).dup)}).join("\t") }).join(("\n"))
	end

	def self.get_from_houses(houses)
		Room.includes(:person).where(house: houses).and(Room.where.not(person: nil)).in_order_of(:house, houses).order(room: :asc)
	end

end     #class end
