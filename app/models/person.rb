###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

require_relative '../utils/pulpo_query'

#A class containing the Users data
class Person < ActiveRecord::Base

    has_one :crs
    has_one :personal
    has_one :study
    has_one :room
    
    enum status:    {laico: 0, diacono: 1, sacerdote: 2 }
    enum ctr:       {cavabianca: 0, ctr_dependiente:1, no_ha_llegado:2, se_ha_ido:3   }
    enum n_agd:     {n:0, agd:1}
    

    ATTRIBUTES = 
    {
        "title"             =>   {name: "title",          value: "string",    description: "don, Fr., etc..."},  
        "first_name"        =>   {name: "first name",     value: "string",    description: "first name"},  
        "family_name"       =>   {name: "family name",    value: "string",    description: "family name"},
        "full_name"         =>   {name: "full name",      value: "string",    description: "full name, ex. Alejandro Bertelsen Simonetti"},
        "short_name"        =>   {name: "short name",     value: "string",    description: "a shorter version of the full name, ex. Alejandro Bertelsen"},
        "arrival"           =>   {name: "arrival date",   value: "date",      description: "arrival date to cavabianca"},  
        "departure"         =>   {name: "departure",      value: "date",      description: "departure date to cavabianca"},
        "group"             =>   {name: "group",          value: "string",    description: "group in cavabianca"},
        "email"             =>   {name: "email",          value: "string",    description: "email"},
        "phone"             =>   {name: "phone",          value: "string",    description: "phone number"},
        "birth"             =>   {name: "birthday",       value: "date",      description: "birthday"},                    
        "celebration_info"  =>   {name: "celebra",        value: "string",    description: "cuando celebra"},
        "ctr"               =>   {name: "ctr",            value: "options",   description: "ctr donde vive"},
        "status"            =>   {name: "status",         value: "options",   description:  "laico/diácono/sacerdote"},
        "n_agd"             =>   {name: "n/agd",          value: "options",   description:  "n/agd"},
        "year"              =>   {name: "year",           value: "string",    description:  "año en cavabianca"},
    }
    
    
    ##########################################################################################
	# CALLBACKS
	##########################################################################################
	
	before_save do |person|
		self.full_info = "#{(title.nil? ? "" : title+" ")}#{first_name} #{family_name} #{group}"
        self.full_name = "#{family_name} #{first_name}"
	end

    before_destroy do |person|
		self.crs.destroy
        self.study.destroy
        self.personal.destroy
	end

    def self.update_full_info
        Person.all.each do |p|
            info = "#{(p.title.nil? ? "" : p.title+" ")} #{p.first_name} #{p.family_name}"
            p.update(full_info: info )
        end
    end

    def self.create_from_params(params)
        Person.create Person.prepare_params params
    end

    
    def update_from_params(params)
        update Person.prepare_params params
    end

    # prepares the parameters received from the form to aupdate/create the person object.
    def self.prepare_params(params)
        params.delete("commit")     #get rid of the commint parameter
        params.delete("id")
        return params
    end

    def self.search(search_string, order=nil)
        query = PulpoQuery.new(search_string, order)
        query.status ? Person.includes(:room).find_by_sql(query.to_sql) : []
        #query.status ? Person.include.find_by_sql(query.to_sql) : []
    end

    # retrieves an attribute of the form "person.att_name"
    def get_attribute(attribute_string)
        att_array = attribute_string.split(".")
        table, attribute = att_array[0], att_array[1]
        res = case table
            when "person"   then self[attribute.to_sym]
            when "study"    then self.study[attribute.to_sym]
            when "personal" then self.personal[attribute.to_sym]
            when "crs"      then self.crs[attribute.to_sym]
            when "room"     then self.room[attribute.to_sym]
        end
        res.is_a?(Date) ? res.to_s : res
    end

    def self.get_editable_attributes()
    [
        {name: "group",          value: "string",    description: "group in cavabianca"},
        {name: "ctr",            value: "options",   description: "ctr donde vive"},
        {name: "status",         value: "options",   description:  "laico/diácono/sacerdote"},
        {name: "n/agd",          value: "options",   description:  "n/agd"},
        {name: "year",           value: "string",    description:  "año en cavabianca"},
    ]
    end    
    
    def get_attributes(attributes)
        attributes.map {|att| {att => self.get_attribute(att)} }
    end
end