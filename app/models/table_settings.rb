# table_settings.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-10-22
#---------------------------------------------------------------------------------------
#
require_relative '../utils/pulpo_query'
require 'yaml'
require 'rainbow'

#---------------------------------------------------------------------------------------

# DESCRIPTION
# A class defining a the settings of field.
# -----------------------------------------------------------------------------------------
class TableAttribute

	# name: the name to be displayed as the header in the table. It does not need to martch the field name.
	attr_accessor :name, :table, :field, :order, :css_class, :type, :bulk_edit

	def initialize(table, field, name, order, css_class, type, bulk_edit)
		@table = table
		@field = field
		@name = name
		@order = order
		@css_class = css_class
		@type = type
		@bulk_edit = bulk_edit
	end

	def self.create_from_yaml(att_yaml)
		field = att_yaml["id"]
		table = field.split(".")[0]
		name = att_yaml["name"]
		order = att_yaml["order"]
		css_class = att_yaml["css_class"]
		type = att_yaml["type"]
		bulk_edit = att_yaml["bulk_edit"].nil? ? false : att_yaml["bulk_edit"]
		TableAttribute.new(table, field, name, order, css_class, type, bulk_edit)
	end

	def get_field_name()
		field.split(".")[1]
	end

	alias_method :field_name, :get_field_name

	def set_order(order)
		@order = order
		return self
	end

end #class end


# A class containing the sttings of a table.
# A TableSettings has three main attributes.
# 	1. The attributes to be shown
# 	2. The main DB table
# 	3. Related tables
# For example we can define a view of people that also show their rooms. In that case the
# main table is people while rooms will be a related table.
class TableSettings

	attr_accessor :name, :att, :main_table, :related_tables

	# the path of a yaml file specifying the table settings
	SETTINGS_FILE_PATH = "app/settings/attributes.yaml"
	print Rainbow("PULPO: Loading Tables Settings from config file: #{SETTINGS_FILE_PATH} ... ").yellow
	SETTINGS_YAML = YAML.load_file(SETTINGS_FILE_PATH)

	def initialize(arguments)
		@name 					= arguments[:name]
		@main_table 		= arguments[:main_table]
		@related_tables = arguments[:related_tables]
		@att 						= arguments[:attributes]
	end

	# creates a table from a yaml definition
	def self.create_from_yaml(yaml_definition)
		TableSettings.new (
			{
				name: 					yaml_definition["name"],
				attributes: 		yaml_definition["attributes"].map {|att| ALL_ATTRIBUTES.find {|ta| ta.field==att } },
				main_table: 		yaml_definition["main_table"],
				related_tables: yaml_definition["related_tables"]
			})
	end

	def self.get(table_symb)
		#puts "asking for table #{table_symb}\n\n\n\n"
		#puts "found #{(ALL_TABLES.find {|ts| ts.name.to_sym == table_symb}).inspect}"
		ALL_TABLES.find {|ts| ts.name.to_sym == table_symb}
	end

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

	# returns an array with all the attibute settings present in the TableSettings object
	def self.get_editable_attributes(table=nil)
		ALL_ATTRIBUTES.select{|att| att.bulk_edit}
	end

	def self.get_attribute_by_name(name)
		#puts "looking for attribute #{name} found #{ALL_ATTRIBUTES.find{|a| a.field.split(".")[1]==name}}"
		ALL_ATTRIBUTES.find{|a| a.field.split(".")[1]==name}
	end

	# checks wether an attribute is in the table settings
	def include?(att_name)
		(@att.map{|att| att.field}).include? att_name
	end

	def get_field(field)
		return @att.find{|a| a.field==field}
	end

	def self.get_attribute(field)
		return ALL_ATTRIBUTES.find{|a| a.field==field}
	end

	def main_table
		@main_table
	end

	def main_model_name
		@main_table.singularize
	end

	def order
		order_hash = Hash.new
		@att.select{|a| a.order!="NONE"}.each { |a| order_hash[a.field.to_sym] = (a.order=="ASC" ? :asc : :desc) }
		return order_hash
	end

	def get_order
		order_hash = Hash.new
		@att.select{|a| a.order!="NONE"}.each { |a| order_hash[a.field.to_sym] = (a.order=="ASC" ? :asc : :desc) }
		return order_hash
	end

	# Creates a TableSetting object from the params received from the corresponding form
	def self.create_from_params(table,params)

		# the attributes that will be shown in the table
		selected_attributes = (params.filter { |key,value| value=="true" }).keys

		# get the settings for each attribute
		attributes = selected_attributes.map { |field| TableSettings.get_attribute field }

		# set the order of the attributes.
		attributes = attributes.each do |att|
			att.set_order(params["#{att.field}.order"].nil? ? "NONE" : params["#{att.field}.order"])
		end

		related_tables = case table
			when "people" 	then TableSettings.get(:people_default).related_tables
			when "rooms"  	then TableSettings.get(:rooms_default).related_tables
			when "permits"  then TableSettings.get(:permits_default).related_tables
		end
		main_table = case table
			when "people" 	then TableSettings.get(:people_default).main_table
			when "rooms"  	then TableSettings.get(:rooms_default).main_table
			when "permits"  then TableSettings.get(:permits_default).main_table
		end
		TableSettings.new(name: name, main_table: main_table, attributes: attributes, related_tables: related_tables)
	end

	ALL_ATTRIBUTES = SETTINGS_YAML["attributes"].map {|att| TableAttribute.create_from_yaml att}
	PEOPLE_ALL = TableSettings.new(name: "people_all", main_table: "people", attributes: ALL_ATTRIBUTES)

	ALL_TABLES = SETTINGS_YAML["tables"].map {|t| (TableSettings.create_from_yaml t)}
	ALL_TABLES << PEOPLE_ALL

	puts Rainbow("done!").yellow

end #class end
