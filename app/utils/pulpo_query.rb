
###########################################################################################
# DESCRIPTION
# A class defininign a query object. Its function is to provide some parsing capabities
# to parse query strings and trasnform them into valid sql queries.
###########################################################################################
require_relative '../models/table_settings'

class PulpoQuery

	MAIN_TABLE ="people"
	AND_DELIMITERS = [' AND ', ' and ']
	OR_DELIMETERS = [' ', ' OR ', ' or ']

	TABLES_MODELS =
	{
		"people"		=> :person,
		"personals"	=> :personal,
		"studies"		=> :study,
		"crs"				=> 	:crs,
		"rooms"			=> :room,
		"people"		=> :person,
	}
	ATTRIBUTES = TableSettings.get_all_attributes

	def initialize(query_string, table_settings=nil)
		
		puts "got table settings #{table_settings}"
		@order = table_settings.nil? ? [] : table_settings.get_order
		@tables = table_settings.nil? ? [] : table_settings.get_tables
		
		# clear the main table name and trasform its values to the model name, downcased to match the association
		@tables =  (@tables-[MAIN_TABLE]).map {|table| TABLES_MODELS[table]}
		puts "got tables  #{@tables}"
		
		if query_string.nil?
			@query_array = []
		else
			# clean any whitespaces after colons: i.e. "clothes:  96" will become clothes:96
			query_string = query_string.strip.gsub(/:\s+/, ':')
			
			# clean any more occurence of several white spaces
			query_string = query_string.gsub(/\s+/, ' ')
			
			# split the string into AND clauses
			@query_array = query_string.split(Regexp.union(AND_DELIMITERS))
		end	
	end

	def execute
		if @query_array.empty?
			return Person.all.includes(@tables).order(@order) if MAIN_TABLE=="people"
		end
		puts Rainbow("got query array #{@query_array}").purple
		# execute the OR clauses
		res_array = @query_array.map{|or_clauses| execute_or_clauses(or_clauses)}
		
		# execute the AND clauses
		result = res_array.inject{ |carry, res| (res.nil? || carry.nil?) ? nil : carry.and(res) }
		
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
		attributes_array = query_array.map { |clause| AttributeQuery.new(clause,@tables) }
		
		# use only the well formed attributes
		attributes_array = attributes_array.select { |att| att.status }
		
		attributes_array = attributes_array.map { |clause| clause.execute }
		puts "got attributes array after executing or clauses #{attributes_array}"
		
		attributes_array.inject{ |res, condition| condition.nil? ? res : res.or(condition) }
	end
	
end # class end

class AttributeQuery

    MAIN_TABLE ="people"
    DEFAULT_ATTRIBUTE = "full_name"
    RELATED_TABLE_ID = "person_id"

    ATTRIBUTES = PulpoQuery::ATTRIBUTES

    NAME_ALIASES = {
			"name"          => "full_name",
			"nombre"        => "full_name",
			"ropa"          => "clothes",
			"numero"        => "clothes",
			"número"        => "clothes",
			"año"           => "year",
			"grupo"         => "group",
			"center"        => "ctr",
			"centro"        => "ctr",
			"n"             => "n_agd",
			"agd"           => "n_agd",
			"prom"          => "classnumber",
			"promocion"     => "classnumber",
			"promoción"     => "classnumber",
    }
    
    VALUE_ALIASES = {
			"laico"          		=> 0,
			"diacono"        		=> 1,
			"diácono"        		=> 1,
			"sacerdote"      		=> 2,
			"sacd"           		=> 2,
			"n"              		=> 0,
			"agd"            		=> 1,
			"cavabianca"     		=> 0,
			"cb"               	=> 0,
			"ctr dependiente"   => 1,
			"dep"               => 1,
			"ctr dep"           => 1,
			"left"              => 2,
			"gone"              => 2,
			"se fue"            => 2,
			"se fueron"         => 2,
    }
    
		QUERY_ALIASES = {
			"sacd"          => "status:sacd",
			"sacerdote"     => "status:sacd",
			"sacerdotes"    => "status:sacd",
			"agregado"      => "n_agd:agd",
			"agregados"     => "n_agd:agd",
			"laicos"        => "status:laico",
			"laico"         => "status:laico",
			"cb"            => "ctr:cb",
			"cavabianca"    => "ctr:cb",
			"dep"           => "ctr:dep",
    }
    

		attr_accessor :status

    def initialize(query_string, tables)
        
		@tables	= tables
		#replace the query alias if found
		query_string = QUERY_ALIASES[query_string] unless QUERY_ALIASES[query_string].nil?
		
		query_array = query_string.split(":")
		
		# if the query string is not of the form att:value but only a simple string "value"
		#  we replace it with the defaull attribute i.e. default_attibuete:value  
		if query_array[1].nil?
			@att_name = DEFAULT_ATTRIBUTE
			@att_value = query_array[0]
		else
			@att_name = query_array[0]
			@att_value = query_array[1]
		end
		
		#check whether there an alias is used for the attribute name or for the attribute value
		@att_name = NAME_ALIASES[@att_name] unless NAME_ALIASES[@att_name].nil?
		@att_value = VALUE_ALIASES[@att_value] unless VALUE_ALIASES[@att_value].nil?
		
		# if the attribute name is not found in the attributes list we set the status to false
		@status = !TableSettings.get_attribute_by_name(@att_name).nil?  

	end

	def execute
		
		return nil if !@status
		
		att = TableSettings.get_attribute_by_name(@att_name)
		table, field_name = att.field.split(".")
		puts Rainbow("searching @att_name #{@att_name} got #{att} table:#{att.table} filed:#{att.field} type:#{att.type}").yellow
		
		condition = case att.type
			when "string"
				"#{att.field} ILIKE '%#{@att_value}%'"
			when "integer", "enum"
				# if the value cannot be cast into an integer we set a value of -1 to return an empty set
				if Integer(@att_value, exception: false).nil?   
					{att.field.to_sym => -1}
				else
					{att.field.to_sym => @att_value}
				end
			when "date"
				if Integer(@att_value, exception: false).nil?
					"date_part('year', #{att.field})=-1"
				else
					"date_part('year', #{att.field})=#{@att_value}"
				end
			end
			puts "built condtion #{condition}"
		
			# the code is a bit complex but it allows us to include in the query the tables that are needed to show the records
		# and avoid n+1 queries
		puts "condition:#{condition} tables:#{@tables}"
		case table
			when "people" then (@tables.empty? ? Person.where(condition) : Person.includes(@tables).where(condition))
			when "personals" then (@tables.empty? ? Person.joins(:personal).where(condition) : Person.includes(@tables).joins(:personal).where(condition)) 
			when "studies" then (@tables.empty? ? Person.joins(:study).where(condition) : Person.includes(@tables).joins(:study).where(condition)) 
			when "crs" then (@tables.empty? ? Person.joins(:crs).where(condition) : Person.includes(@tables).joins(:crs).where(condition)) 
			when "rooms" then (@tables.empty? ? Person.joins(:room).where(condition) : Person.includes(@tables).joins(:room).where(condition)) 
		end
	end

end #class end
