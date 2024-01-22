###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

require_relative '../utils/pulpo_query'
require 'yaml'
require 'rainbow'

class TableAttribute
		
	attr_accessor :table, :field, :order, :css_class, :type, :name

	def initialize(table, field, name, order, css_class, type)
		@table = table
		@field = field
		@name = name
		@order = order
		@css_class = css_class
		@type = type
	end
	
	def self.create_from_yaml(att_yaml)
		field = att_yaml["id"]
		table= field.split(".")[0]
		name = att_yaml["name"]
		order = att_yaml["order"]
		css_class = att_yaml["css_class"]
		type = att_yaml["type"]
		return TableAttribute.new(table, field, name, order, css_class, type)
	end

	def set_order(order)
		@order = order
		return self
	end
	
end #class end


#A class containing the Users data
class TableSettings
	
	attr_accessor :att, :main_table, :related_tables
	
	SETTINGS_FILE_PATH = "app/settings/attributes.yaml"
	print Rainbow("PULPO: Loading Tables Settings from config file: #{SETTINGS_FILE_PATH} ... ").yellow
	SETTINGS_YAML = YAML.load_file(SETTINGS_FILE_PATH)

	def initialize(args)	# an array containing the attributtes to be shown in the table
		case args[:table]
			when :people_default 		
				@att = DEFAULT_PEOPLE_TABLE[:attributes]
				@main_table = DEFAULT_PEOPLE_TABLE[:main_table]
				@related_tables = DEFAULT_PEOPLE_TABLE[:related_tables]
			when :rooms_default 		
				@att = DEFAULT_ROOMS_TABLE[:attributes]
				@main_table = DEFAULT_ROOMS_TABLE[:main_table]
				@related_tables = DEFAULT_ROOMS_TABLE[:related_tables]
			when :people_all			
				@att = ALL_PEOPLE_TABLE[:attributes]
				@main_table = ALL_PEOPLE_TABLE[:main_table]
			else 
				@att = args[:attributes]
				@main_table = args[:main_table]
				@related_tables = args[:related_tables]
			end
		#puts Rainbow("initialized table settings with attributes: #{@att} and main_table: #{@main_table} ").yellow
	end

	ALL_ATTRIBUTES = SETTINGS_YAML["attributes"].map {|att| TableAttribute.create_from_yaml att}	
	ALL_PEOPLE_TABLE = 
	{
		main_table: "people",
		attributes: ALL_ATTRIBUTES
	}
	DEFAULT_PEOPLE_TABLE = 
	{
		main_table: SETTINGS_YAML["default_people_table"]["main_table"],
		related_tables: SETTINGS_YAML["default_people_table"]["related_tables"],
		attributes: SETTINGS_YAML["default_people_table"]["attributes"].map {|att| ALL_ATTRIBUTES.find {|ta| ta.field==att }}
	}

	DEFAULT_ROOMS_TABLE = 
	{
		main_table: SETTINGS_YAML["default_rooms_table"]["main_table"],
		related_tables: SETTINGS_YAML["default_rooms_table"]["related_tables"],
		attributes: SETTINGS_YAML["default_rooms_table"]["attributes"].map {|att| ALL_ATTRIBUTES.find {|ta| ta.field==att }}
	}
	 	
	puts Rainbow("done!").yellow
	
	def self.get_all_attributes
		return ALL_ATTRIBUTES
	end
	# returns an array with all the table names present in the table settings
	def get_tables
		return @att.uniq{|att| att.table}.map{|att| att.table}
	end
	
	# returns an array with all the attibute settings present in the TableSettings object
	def get_attributes(table=nil)
		table.nil? ? @att : @att.select{|att| att.table==table}
	end

	# checks wether an attribute is in the table settings
	def include? att_name
		(@att.map{|att| att.field}).include? att_name
	end

	def get_fields
		return @att.map{|a| a.field}
	end
	
	def get_field(field)
		return @att.find{|a| a.field==field}
	end
	
	def get_names
		return @att.map{|a| a.name}
	end

	def get_columns()
		return @att
	end

	def self.get_attribute(field)
		return ALL_ATTRIBUTES.find{|a| a.field==field}
	end

	def self.get_attribute_by_name(name)
		return ALL_ATTRIBUTES.find{|a| a.field.split(".")[1]==name}
	end

	def get_order
		order_hash = Hash.new
		@att.select{|a| a.order!="NONE"}.each { |a| order_hash[a.field.to_sym] = (a.order=="ASC" ? :asc : :desc) }
		return order_hash
	end
	# Creates a TableSetting object from the params received from the corresponding form	
	def self.create_from_params(table,params)
		selected_attributes = (params.filter { |key,value| value=="true" }).keys
		
		attributes = selected_attributes.map { |field| TableSettings.get_attribute field }
		
		attributes = attributes.each do |att| 
			att.set_order(params["#{att.field}.order"].nil? ? "NONE" : params["#{att.field}.order"])
		end
		
		related_tables = case table
			when "people" then DEFAULT_PEOPLE_TABLE[:related_tables] 
			when "rooms"  then DEFAULT_ROOMS_TABLE[:related_tables] 
		end

		TableSettings.new(main_table: table, attributes: attributes, related_tables: related_tables)
	end

end #class end
