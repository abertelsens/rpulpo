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
            name:                   params[:name],
            floor:                  params[:floor],
            bed:                    params[:bed],
            matress:                params[:matress],
            bathroom:               params[:bathroom],
            phone:                  params[:phone]
        }
    end

    def self.search(search_string, order=nil)
        puts "got search string #{search_string}"
        puts "SELECT * from rooms WHERE rooms.name ILIKE '%#{@search_string}%'"
        return Room.find_by_sql("SELECT * from rooms WHERE rooms.name ILIKE '%#{search_string}%'")
        #query.status ? Person.include.find_by_sql(query.to_sql) : []
    end

    def self.get_empty_rooms_by_house()
        houses.map {|house| {house: house[0].humanize, occupied:Room.where(house: house).where.not(person_id: nil).size, empty: Room.where(house: house, person_id: nil).size}}
    end

    def self.get_empty_rooms()
        {occupied:Room.where.not(person_id: nil).size, empty: Room.where(person_id: nil).size }
    end


end     #class end