###########################################################################################
# DESCRIPTION
# A class defininign a Room object.
###########################################################################################


#A class containing the Users data
class Room < ActiveRecord::Base

    
    belongs_to 	    :person    
    enum house:     {dirección: 0, profesores: 1, pabellón: 2, sala_de_conferencias: 3, altana: 4, chiocciolla: 5, mulino: 6, borgo:7, ospiti:8, enfermería: 9, casa_del_consejo: 10}
    enum bed:       {normal: 0, larga: 1, reclinable: 2}
    enum bathroom:  {individual: 0, común: 1}

    # if a set is destroyed all the related records in the personsets are destroyed
	#before_destroy do |doc|
    #    full_path = doc.get_full_path
    #    FileUtils.rm full_path if File.file? full_path
    #end

    def self.create_from_params(params)
        return Room.create Room.prepare_params params
    end
    
    def update_from_params(params)
        return update Room.prepare_params params
    end

    def self.prepare_params(params)
        {
            person_id:              params[:person].blank? ? nil : params[:person],
            house:                  params[:house],
            room:                   params[:room],
            floor:                  params[:floor],
            bed:                    params[:bed],
            matress:                params[:matress],
            bathroom:               params[:bathroom],
            phone:                  params[:phone]
        }
    end

    def self.search(search_string, table_settings=nil)
        query = PulpoQuery.new(search_string, table_settings)
        query.execute
    end

    def self.get_rooms_count_by_house()
        empty = Room.group(:house).where(person_id:nil).count 
        total = Room.group(:house).order(house: :asc).count
        total.keys.map {|key| { "room" => key.to_s, "total" => total[key], "empty" => (empty[key].nil? ? "-" :  empty[key]) } }      
    end

    # retrieves an attribute of the form "person.att_name"
    def get_attribute(attribute_string)
        table, attribute = attribute_string.split(".")
        res = case table
            when "rooms"     then self[attribute.to_sym]
            when "person", "people" then self.person.nil? ? "-" : self.person[attribute.to_sym]
        end
        res = "-" if (res.nil? || res.blank?)
        res.is_a?(Date) ? res.strftime("%d-%m-%y") : res
    end

    def self.collection_to_csv(rooms,table_settings)
        result = (table_settings.att.map{|att| att.name}).join("\t") + "\n"
        result << (rooms.map {|room| (table_settings.att.map{|att| (room.get_attribute(att.field).dup)}).join("\t") }).join(("\n"))
    end

end     #class end