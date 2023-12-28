###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

require_relative '../utils/pulpo_query'

#A class containing the Users data
class PeopleTable

	ATTRIBUTES =
	[
		{
			table: "person",
			attributes: [
				{ field: 	"person.family_name", order: 	"ASC",	class: "long-field",	type: "string" },
				{ field: 	"person.first_name", 	order: 	"ASC",	class: "long-field",	type: "string" },
				{ field: 	"person.group", 			order: 	nil,		class: "short-field u-text-center",	type: "string" 	},
				{ field: 	"person.status", 			order: 	nil,		class: "medium-field", type: "string" 	},
				{ field: 	"person.ctr", 				order: 	nil,		class: "medium-field", type: "enum" 	},
				{ field: 	"person.year", 				order: 	nil,		class: "short-field u-text-center", type: "string" 	},
				{ field: 	"person.title", 				order: 	nil,		class: "short-field u-text-center", type: "string" 	},
			]
		},
		{
			table: "room",
			attributes: [
				{ field: 	"room.house", 				order: 	nil,		class: "medium-field", type: "enum" 	},
				{ field: 	"room.name", 					order: 	nil,		class: "medium-field", type: "string" 	},
			]
		}

	]

	DEFAULT_TABLE = [
		{ field: 	"person.family_name", order: 	"ASC",	class: "long-field",	type: "string" },
		{ field: 	"person.first_name", 	order: 	"ASC",	class: "long-field",	type: "string" },
		{ field: 	"person.group", 			order: 	nil,		class: "short-field u-text-center",	type: "string" 	},
		{ field: 	"person.status", 			order: 	nil,		class: "medium-field", type: "string" 	},
		{ field: 	"person.ctr", 				order: 	nil,		class: "medium-field", type: "enum" 	},
		{ field: 	"person.year", 				order: 	nil,		class: "short-field u-text-center", type: "string" 	},
		{ field: 	"room.house", 				order: 	nil,		class: "medium-field", type: "enum" 	},
		{ field: 	"room.name", 					order: 	nil,		class: "medium-field", type: "string" 	},
]

SMALL_TABLE = [
	{ field: 	"person.family_name", order: 	"ASC",	class: "long-field",	type: "string" },
	{ field: 	"person.first_name", 	order: 	"ASC",	class: "long-field",	type: "string" },
	{ field: 	"person.group", 			order: 	nil,		class: "short-field u-text-center",	type: "string" 	},
	{ field: 	"person.year", 				order: 	nil,		class: "short-field u-text-center", type: "string" 	},
]

	def initialize(args)	# an array containing the attributtes to be shown in the table
		@att = DEFAULT_TABLE if args[:table]==:default
		@att = SMALL_TABLE if args[:table]==:small
	end

	def self.get_attributes
		return ATTRIBUTES
	end
	
	def get_setting(field_name)
		((@att.map{|att| att[:field]}).include? field_name) ? "true" : "false"
	end
	
	def get_columns()
		return @att
	end
	# params: {"person.family_name.order"=>"NONE", "person.family_name"=>"true", "person.first_name.order"=>"NONE", "person.first_name"=>"true", "person.group.order"=>"NONE", "person.group"=>"true", "person.status.order"=>"NONE", "person.status"=>"true", "person.ctr.order"=>"NONE", "person.ctr"=>"true", "person.year.order"=>"NONE", "person.year"=>"true", "person.title.order"=>"NONE", "person.title"=>"false", "room.house.order"=>"NONE", "room.house"=>"true", "room.name.order"=>"NONE", "room.name"=>"true", "commit"=>"save", "splat"=>["people/table/settings"]}
	def self.create_from_params(params)
		params.delete("commit").delete("splat")
		attributes = ATTRIBUTES.map do |table|
			{	
				table: table[:table],
				attributes: table[:attributes].select { |att| params.keys.include? att[:field]  }
			}
		end
	
		puts "\n\nstting attributes> #{attributes}\n\n" 
		#attributes = attributes.map do |table|
		#	table[:attributes].map { |att| att[:order]= params[att[:field]]  }
		#end
	end
end #class end

