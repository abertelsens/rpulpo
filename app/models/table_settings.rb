###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

require_relative '../utils/pulpo_query'
require 'yaml'

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
	
	attr_accessor :att
	
	SETTINGS_FILE_PATH = "app/settings/attributes.yaml"
	SETTINGS_YAML = YAML.load_file(SETTINGS_FILE_PATH)

	#ALL_TABLE = [TableAttribute::FAMILY_NAME, TableAttribute::FIRST_NAME, TableAttribute::GROUP, TableAttribute::STATUS, TableAttribute::N_AGD, TableAttribute::CTR, TableAttribute::YEAR, TableAttribute::REGION, TableAttribute::CLASS_NUMBER,  TableAttribute::HOUSE, TableAttribute::ROOM, TableAttribute::ADMISSIO ] 
	def initialize(args)	# an array containing the attributtes to be shown in the table
		@att = case args[:table]
			when :default 		then DEFAULT_TABLE
			when :small 		then SMALL_TABLE
			when :all			then ALL_TABLE
			else args[:table]
			end
	end

	ALL_TABLE = SETTINGS_YAML["attributes"].map {|att| TableAttribute.create_from_yaml att}	
	DEFAULT_TABLE = SETTINGS_YAML["default_table"]["attributes"].map {|att| ALL_TABLE.find {|ta| ta.field==att } }	
	SMALL_TABLE = SETTINGS_YAML["small_table"]["attributes"].map {|att| ALL_TABLE.find {|ta| ta.field==att } }	
	
	
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
		return ALL_TABLE.find{|a| a.field==field}
	end

	# Creates a TableSetting object from the params received from the corresponding form	
	def self.create_from_params(params)
		selected_attributes = (params.filter { |key,value| value=="true" }).keys
		attributes = selected_attributes.map { |field| TableSettings.get_attribute field }
		attributes = attributes.map { |att| att.set_order params["#{att.field}.order"] }
		return TableSettings.new(table: attributes)
	end

end #class end

