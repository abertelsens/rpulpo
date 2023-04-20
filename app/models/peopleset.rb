###########################################################################################
# DESCRIPTION
# A class defininign a set of people.
# author: abs@saxum.org
###########################################################################################

class Peopleset < ActiveRecord::Base

    SAVED = 0
    TEMPORARY = 1

    ##########################################################################################
	# CALLBACKS
	##########################################################################################
	
	# if a set is destroyed all the related records in the personsets are destroyed
	before_destroy do |ps|
        personsets = Personset.where(peopleset_id: ps.id).destroy_all()
    end

    ##########################################################################################
	# STATIC
	##########################################################################################
	
    def self.create_from_params(params)
        Peopleset.create({name: params[:name], status: SAVED})
    end

    # returns a temporary set, if it does not exist, we create it.
    def self.get_temporary_set()
        set = Peopleset.where(status: TEMPORARY)
        set.empty? ? Peopleset.create({status: TEMPORARY}) : set[0]
    end


    ##########################################################################################
	# ACCESSORS
	##########################################################################################
	
    def get_people()
        Person.joins("INNER JOIN personsets ON people.id = personsets.person_id AND personsets.peopleset_id = '#{self.id}'").order(family_name: :asc)
    end

    # chechs wheter the set contains a person
    def contains?(person)
        Personset.where(person_id: person.id, peopleset_id: self.id).size>0
    end

    def self.get_all
        Peopleset.all().order(status: :desc, name: :asc)
    end
    
    def can_be_deleted?
        true
    end

    def get_name
        status==TEMPORARY ? "Temporary List" : name
    end

    def temporary?
        status==TEMPORARY
    end

    ##########################################################################################
	# MODIFIERS
	##########################################################################################

    def add_person(person)
        Personset.create(peopleset_id: self.id, person_id: person.id)
        return self
    end
    
    def remove_person(person)
        ps = Personset.where(peopleset_id: self.id, person_id: person.id).destroy_all()
        return self
    end
    
    def set_people(people)
        people.each {|person| add_person person}
    end

    # adds people to the set
    # @params - people_ids: an array of ids of people
    def add_people(people_ids)
        people_ids = people_ids.map {|pid| pid.to_i}
        current_people = Personset.where(peopleset_id: self.id).pluck(:person_id)
        new_people = people_ids - current_people
        new_people.each {|pid| Personset.create(peopleset_id: self.id, person_id: pid)}
        return self
    end

    def remove_people(people_ids)
        people_ids = people_ids.map {|pid| pid.to_i}
        people_ids.each {|pid|  Personset.where(peopleset_id: self.id, person_id: pid).destroy_all } 
        return self
    end

    # edits an attribure of the peopel in the set.
    # @params - att_name:   the name of the attribure to be edited
    # @params - value:      the value of the attribute to be edited
    def edit(att_name,value)
        get_people.each {|person| person.update(att_name.to_sym => value)}
    end

    # toggles a person from the set
    def toggle(person)
        (contains? person) ? (remove_person person) : (add_person person)
    end

end

class Personset < ActiveRecord::Base

    belongs_to  :peopleset
    belongs_to  :person

end