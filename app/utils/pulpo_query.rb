
###########################################################################################
# DESCRIPTION
# A class defininign a query object. Its function is to provide some parsing capabities
# to parse query strings and trasnform them into valid sql queries.
###########################################################################################

class PulpoQuery

    MAIN_TABLE ="people"
    AND_DELIMITERS = [' AND ', ' and ']
    OR_DELIMETERS = [' ', ' OR ', ' or ']

    ATTRIBUTES = {
        "family_name"   => {table:  "people",    name:  "family_name",  type:   "string"},
        "full_name"     => {table:  "people",    name:  "full_name",    type:   "string"},
        "clothes"       => {table:  "people",    name:  "clothes",      type:   "string"},
        "year"          => {table:  "people",    name:  "year",         type:   "string"},
        "group"         => {table:  "people",    name:  "group",        type:   "string"},
        "ctr"           => {table:  "people",    name:  "ctr",          type:   "integer"},
        "n_agd"         => {table:  "people",    name:  "n_agd",        type:   "integer"},
        "status"        => {table:  "people",    name:  "status",       type:   "integer"},
        "region"        => {table:  "personals", name:  "region",       type:   "string"},
        "classnumber"   => {table:  "crs",       name:  "classnumber",  type:   "string"},
        "admissio"      => {table:  "crs",       name:  "admissio",     type:   "date"},
        "room"          => {table:  "rooms",     name:  "name",         type:   "string"},
    }

    def initialize(query_string, order)
        
        # clean any whitespaces after colons: i.e. "clothes:  96" will become clothes:96
        query_string = query_string.gsub(/:\s+/, ':')
        
        # clean any more occurence of several white spaces
        query_string = query_string.gsub(/\s+/, ' ')
        
        # split the string into and clauses
        query_array = query_string.split(Regexp.union(AND_DELIMITERS))
        
        # build the clauses and select only those which are not blank. 
        # The parser returns a blank clauses if it is not well formed 
        clauses = query_array.map {|clause| parse_or_clauses(clause) }
        clauses = clauses.select { |clause| !clause.blank? }
        @status = !clauses.empty? || query_string.blank?
        order_array = (order.blank? ? ["family_name","ASC"] :  order.split(" ") )# the order parameter is of the form "clothes ASC"
        puts "setting order array to: #{order_array}"
        if order_array[0]=="family_name"
            @order = "ORDER BY #{ATTRIBUTES[order_array[0]][:table]}.#{ATTRIBUTES[order_array[0]][:name]} #{order_array[1]}"
        else
            @order = "ORDER BY #{ATTRIBUTES[order_array[0]][:table]}.#{ATTRIBUTES[order_array[0]][:name]} #{order_array[1]}, people.family_name ASC"
        end
        @sql_query = clauses.join(" AND ")
        
    end

    def to_sql
        if @sql_query.blank?
            "SELECT * FROM #{MAIN_TABLE} #{@order};"
        else
            "SELECT * FROM #{MAIN_TABLE} WHERE #{@sql_query} #{@order};"
        end
    end
    
    def status
        return @status
    end
    
    # A clause is a string fo the form "attibute:value" or a concatenation of the form "attibute:value (OR) attibute:value"
    def parse_or_clauses(query_string)
        
        query_array = query_string.split(Regexp.union(OR_DELIMETERS))
        
        # transform the clauses into Attributes Queries
        attributes_array = query_array.map { |clause| AttributeQuery.new(clause) }
        
        # use only the well formed attributes
        attributes_array = attributes_array.select { |att| att.status }

        attributes_array = attributes_array.map{ |att| "( #{att.to_sql_condition} )" }
        
        return  attributes_array.join(" OR ")
        
    end

    
end

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
        "laico"          => 0,
        "diacono"        => 1,
        "diácono"        => 1,
        "sacerdote"      => 2,
        "sacd"           => 2,
        "n"              => 0,
        "agd"            => 1,
        "cavabianca"     => 0,
        "cb"               => 0,
        "ctr dependiente"   => 1,
        "dep"               => 1,
        "ctr dep"            => 1,
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
        

    def initialize(query_string)
        
        #replace the query alias if found
        query_string = QUERY_ALIASES[query_string] unless QUERY_ALIASES[query_string].nil?
        query_array = query_string.split(":")
        
        # if the query string is not of the form att:value but only a simple string "value"
        #  we replace it with the defaull attrinute i.e. default_attibuete:value  
        if query_array[1].nil?
            @att_name = DEFAULT_ATTRIBUTE
            @att_value = query_array[0]
        else
            @att_name = query_array[0]
            @att_value = query_array[1]
        end
        
        #check whether there an alias is used for the attribute name
        @att_name = NAME_ALIASES[@att_name] unless NAME_ALIASES[@att_name].nil?
        @att_value = VALUE_ALIASES[@att_value] unless VALUE_ALIASES[@att_value].nil?
        
        # if the attribute name is not faound in the attributes list we set the status to false
        @status = !ATTRIBUTES[@att_name].nil?  
    end

    def status
        @status
    end
    
    
    def to_sql_condition
        
        # if the attribute is not in the main table we build a related table query
        if ATTRIBUTES[@att_name][:table]==MAIN_TABLE
            self.build_condition
        else
            "#{MAIN_TABLE}.id IN (SELECT #{RELATED_TABLE_ID} from #{ATTRIBUTES[@att_name][:table]} WHERE (#{self.build_condition}))"
        end
    end

    def build_condition
        case ATTRIBUTES[@att_name][:type]
        when "string"
            "#{ATTRIBUTES[@att_name][:table]}.#{ATTRIBUTES[@att_name][:name]} ILIKE '%#{@att_value}%'"
        when "integer"
            # if the value cannot be cast into an integer we set a value of -1 to return an empty set
            if Integer(@att_value, exception: false).nil?   
                "#{ATTRIBUTES[@att_name][:table]}.#{ATTRIBUTES[@att_name][:name]}=-1"
            else
                "#{ATTRIBUTES[@att_name][:table]}.#{ATTRIBUTES[@att_name][:name]}=#{@att_value}"
            end
        when "date"
            "date_part('year', #{ATTRIBUTES[@att_name][:table]}.#{ATTRIBUTES[@att_name][:name]})=#{@att_value}"
        end
    end

    def to_sql
        "SELECT * from #{MAIN_TABLE} WHERE #{self.to_sql_condition}"
    end

end
