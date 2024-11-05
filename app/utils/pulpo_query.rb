

# pulpo_query.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defininig a query object. Its function is to provide some parsing capabities
# to parse query strings and trasnform them into valid sql queries.
#---------------------------------------------------------------------------------------

require_relative '../models/table_settings'

class PulpoQuery

	AND_DELIMITERS = [' AND ', ' and ']
	OR_DELIMETERS = [' ', ' OR ', ' or ']

	SETTINGS_FILE_PATH = "app/settings/query_settings.yaml"
	SETTINGS_YAML = YAML.load_file(SETTINGS_FILE_PATH)
	QUERY_ALIASES = SETTINGS_YAML["query_aliases"].map {|al| {from: al.first[0], to: al.first[1]} }
	NAME_ALIASES = SETTINGS_YAML["name_aliases"]
	ATTRIBUTES = TableSettings.get_all_attributes

	def initialize(query_string, table_settings=nil)
		@order =		 	table_settings.nil? ? [] : table_settings.get_order
		@main_table = table_settings.nil? ? [] : table_settings.main_table
		@tables = 		table_settings.nil? ? [] : table_settings.get_tables
		@models = 		(@tables-[@main_table]).map {|table| table.singularize}

		if query_string.nil? then @query_array = []
		else

			# clean any ' character
			query_string = query_string.strip.gsub(/'+/, '')
			# clean any whitespaces after colons: i.e. "clothes:  96" will become clothes:96
			query_string = query_string.strip.gsub(/:\s+/, ':')
			# clean any more occurence of several white spaces
			query_string = query_string.gsub(/\s+/, ' ')

			#replace the query alias if found
			QUERY_ALIASES.each { |pair| query_string.gsub!(/#{pair[:from]}/, pair[:to]) }

			# split the string into AND clauses
			@query_array = query_string.split(Regexp.union(AND_DELIMITERS))
		end
	end

	def execute
		if @query_array.empty?
			return Person.all.includes(@models).order(@order) if @main_table=="people"
			return Room.all.includes(@models).order(@order) 	if @main_table=="rooms"
			return Permit.all.includes(@models).order(@order) 	if @main_table=="permits"
		end

		# execute the OR clauses
		res_array = @query_array.map{|or_clauses| execute_or_clauses(or_clauses)}

		# execute the AND clauses
		result = res_array.inject{ |carry, res| (res.nil? || carry.nil?) ? nil : carry.merge(res) }

		result.nil? ? [] : result.order(@order)
	end

	def status
		return @status
	end

	# A clause is a string fo the form "attibute:value" or a concatenation of the form "attibute:value (OR) attibute:value"
	def execute_or_clauses(query_string)

		#puts "executin execute_or_clauses of string #{query_string}"
		query_array = query_string.split(Regexp.union(OR_DELIMETERS))

		# transform the clauses into Attributes Queries
		attributes_array = query_array.map { |clause| AttributeQuery.new(clause, @main_table, @models) }

		# use only the well formed attributes
		attributes_array = attributes_array.select { |att| att.status }

		attributes_array = attributes_array.map { |clause| clause.execute }
		puts "got attributes array after executing or clauses #{attributes_array}"

		attributes_array.inject{ |res, condition| condition.nil? ? res : res.or(condition) }
	end

end # class end

class AttributeQuery

	MAIN_TABLE ="people"
	DEFAULT_ATTRIBUTES = {"people" => "full_name", "rooms" => "room", "permits" => "full_name" }

	ATTRIBUTES = PulpoQuery::ATTRIBUTES
	NAME_ALIASES = PulpoQuery::NAME_ALIASES

	attr_accessor :status

	def initialize(query_string, main_table, models)
		@main_table	= main_table
		@models	= models
		query_array = query_string.split(":")

		# if the query string is not of the form att:value but only a simple string "value"
		#  we replace it with the defaull attribute i.e. default_attribute:value
		if query_array[1].nil?
			@att_name = DEFAULT_ATTRIBUTES[@main_table]
			@att_value = query_array[0]
		else
			@att_name = query_array[0]
			@att_value = query_array[1]
		end

		#check whether there an alias is used for the attribute name or for the attribute value
		@att_name = NAME_ALIASES[@att_name] unless NAME_ALIASES[@att_name].nil?

		# if the attribute name is not found in the attributes list we set the status to false
		@status = TableSettings.get_attribute_by_name(@att_name)!=nil

	end

	def execute

		return nil if !@status

		att = TableSettings.get_attribute_by_name(@att_name)
		table, field_name = att.field.split(".")
		puts Rainbow("searching @att_name: #{@att_name.inspect}. Got #{att} table:#{att.table} field:#{att.field} type:#{att.type} att.value #{@att_value}" ).yellow

		condition = case att.type
			when "string" then	"#{att.field} ILIKE '%#{@att_value}%'"
			when "integer", "enum"
				# if the value cannot be cast into an integer we set a value of -1 to return an empty set
				if Integer(@att_value, exception: false).nil? then	"#{att.field}=-1"
				else	"#{att.field}=#{@att_value}"
				end
			when "date"
				if Integer(@att_value, exception: false).nil? then "date_part('year', #{att.field})=-1"
				else "date_part('year', #{att.field})=#{@att_value}"
				end
			when "boolean" then "#{att.field}=#{@att_value=="true"}"
			end

		# the code is a bit complex but it allows us to include in the query the tables that are needed to show the records
		# and avoid n+1 queries
		case @main_table
			when "people", "permits"
				case table
				when "people" then (@models.empty? ? Person.where(condition) : Person.includes(@models).where(condition))
				else (@models.empty? ? Person.joins(table.singularize.to_sym).where(condition) : Person.includes(@models).joins(table.singularize.to_sym).where(condition))
				end
			when "rooms"
				case table
				when "rooms" then (@models.empty? ? Room.where(condition) : Room.includes(@models).where(condition))
				when "people" then (@models.empty? ? Room.joins(:person).where(condition) : Room.includes(@models).joins(:person).where(condition))
				end
			end
	end

end #class end
