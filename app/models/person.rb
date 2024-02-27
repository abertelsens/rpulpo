# -----------------------------------------------------------------------------------------
# DESCRIPTION
# A class defininign a person.
# -----------------------------------------------------------------------------------------

require_relative '../utils/pulpo_query'

#A class containing the Users data
class Person < ActiveRecord::Base

    has_one :crs, dependent: :destroy
    has_one :personal, dependent: :destroy
    has_one :study, dependent: :destroy
    has_one :room

    enum status:    {laico: 0, diacono: 1, sacerdote: 2 }
    enum ctr:       {cavabianca: 0, ctr_dependiente:1, no_ha_llegado:2, se_ha_ido:3   }
    enum n_agd:     {n:0, agd:1}
    enum vela:      {normal:0, no:1, primer_turno:2, ultimo_turno:3}

=begin
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
=end

    # -----------------------------------------------------------------------------------------
    # CALLBACKS
    # -----------------------------------------------------------------------------------------

	before_save do
		full_info = "#{(title.nil? ? "" : title+" ")}#{first_name} #{family_name} #{group}"
    full_name = "#{family_name}, #{first_name}"
	end

	def self.create_from_params(params)
		Person.create Person.prepare_params params
	end

	def update_from_params(params)
		update Person.prepare_params params
	end

	# prepares the parameters received from the form to aupdate/create the person object.
	def self.prepare_params(params)
		params["student"] = params["student"]=="true"
		params.except("commit", "id", "photo_file")
	end

	def self.search(search_string, table_settings=nil)
		(PulpoQuery.new(search_string, table_settings)).execute
	end

	# retrieves an attribute of the form "person.att_name"
	def get_attribute(attribute_string)
		table, attribute = attribute_string.split(".")
		res = case table
				when "person", "people" then self[attribute.to_sym]
				when "studies"          then (study.nil? ? "" : self.study[attribute.to_sym])
				when "personals"        then (personal.nil? ? "" : self.personal[attribute.to_sym])
				when "crs"              then (crs.nil? ? "" : self.crs[attribute.to_sym])
				when "rooms"            then (room.nil? ? "" : self.room[attribute.to_sym])
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
			options  = ["normal", "no", "primer_turno", "ultimo_turno"]
			update(vela: options[((options.find_index vela)+1)%options.size])
	end
end
