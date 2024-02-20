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
    enum vela:      {normal:0, no:1, primer_turno:2, ultimo_turno:3}


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

	before_save do
        puts "running callback before save on #{self}"
		self.full_info = "#{(title.nil? ? "" : title+" ")}#{first_name} #{family_name} #{group}"
        self.full_name = "#{family_name}, #{first_name}"
	end

    before_destroy do |person|
		self.crs&.destroy
        self.study&.destroy
        self.personal&.destroy
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
        params.delete("photo_file")
        params["student"] = params["student"]=="true"
        return params
    end

    def self.search(search_string, table_settings=nil)
        query = PulpoQuery.new(search_string, table_settings)
        res = query.execute
        puts "got result from query: #{res}"
        res
        #query.status ? Person.includes(:room).find_by_sql(query.to_sql) : []
    end

    # retrieves an attribute of the form "person.att_name"
    def get_attribute(attribute_string)
        table, attribute = attribute_string.split(".")
        res = case table
            when "person", "people"   then self[attribute.to_sym]
            when "studies"    then (self.study.nil? ? "" : self.study[attribute.to_sym])
            when "personals" then (self.personal.nil? ? "" : self.personal[attribute.to_sym])
            when "crs"      then (self.crs.nil? ? "" : self.crs[attribute.to_sym])
            when "rooms"     then (self.room.nil? ? "" : self.room[attribute.to_sym])
        end
        res = "-" if (res.nil? || res.blank?)
        puts "\nfound nil while looking for #{attribute_string}" if res.nil?
        res.is_a?(Date) ? res.strftime("%d-%m-%y") : res

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

    def self.collection_to_csv(people,table_settings)
        result = (table_settings.att.map{|att| att.name}).join("\t") + "\n"
        result << (people.map {|person| (table_settings.att.map{|att| (person.get_attribute(att.field).dup)}).join("\t") }).join(("\n"))
    end

    def toggle_vela
        puts "in toggle vela. Got self.vela #{self.vela}"
        vela = case self.vela
        when "normal" then "no"
        when "no" then "primer_turno"
        when "primer_turno" then "ultimo_turno"
        when "ultimo_turno" then "normal"
        end
        puts "in toggle vela. Got vela #{vela}"
        self.update(vela: vela)
    end
end
