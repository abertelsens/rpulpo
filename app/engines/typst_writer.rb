
# typst_writer.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-11-07
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class to produce pdf documents via Typst. See https://typst.app
# The class relies on the typst gem (https://github.com/actsasflinn/typst-rb)
# I was not able to install thr gem in the server so we are writing the outpuf
# files to the file system and cleaning them afterwards. Not ideal...

#---------------------------------------------------------------------------------------

class TypstWriter < DocumentWriter

	# The directory where the typst templates are located.
	TYPST_TEMPLATES_DIR ="app/engines-templates/typst"

	def initialize(document, people, template_variables=nil)
		super()
		@decorator = PersonDecorator.new

		begin
			@template_source = File.read "#{TYPST_TEMPLATES_DIR}/#{document.path}"
		rescue
			set_error(FATAL,"Template #{document.path} not foud in #{TYPST_TEMPLATES_DIR}.
			You should check the settings of #{document.name} file before trying again.")
			return
		end


		puts "\n\nGOT TEMPLATE VARIABLES #{template_variables}\n\n"
		# replace the template variables in the template by their value.
		template_variables.keys.each {|key| @template_source.gsub!("pulpo.#{key}",template_variables[key])} if template_variables

		# stores an array of all the variables found in the template. As we replaced all the template
		# variables, these only include variables related to the people in the db.
		@variables = @template_source.scan(/\$\S*\$/)

		# process each person.
		# replace the variables in the md file with the values retrieved from the DB
		@typst_source = if document.singlepage
			replace_variables_of_set(people)
		else
			(people.map { |person| replace_variables(person) }).join("\n")
		end
	end

	def render(output_type="pdf")
		begin
			clean_tmp_files
			tmp_file_name = "#{rand(10000)}"
			typ_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.tmp.typ"
			pdf_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.tmp.pdf"

			# write the tmp source file to the file system and call the typst comppiler
			File.write typ_file_path, @typst_source
			res =  system("typst compile --root ../.. #{typ_file_path} #{pdf_file_path}")
			res ? (return pdf_file_path) : set_error(FATAL, "Typst Writer: failed to convert document: #{error.message}")

		rescue => error
			set_error(FATAL, "Typst Writer: failed to convert document: #{error.message}")
		end
	end

	# replaces variables with the values corresponding to each person
	# @source: 	the source file content
	# @person:	the person whose data will be used to replace the variables in the text.
	def replace_variables(person)
		@variables.inject(@template_source) {|res, var| res.gsub(var, get_variable_value(var, person)) }
	end

	# gets the value of a variable for a specific person
	# @var: 		the variable identifier. It is of the form $table.field.format$ where format is optional
	# @person:	the person whose data will be used to replace the variables in the text.
	def get_variable_value(var, person)
		# clean the $ characters and parse the variable identifier.
		table, field, format = var.gsub("$","").split(".")
		@decorator.typst_value(person, "#{table}.#{field}", format)
	end


	# gets the value of a variable for a set of people . The result is a string joined by \n for
	# each value. In other words, if you replace the variable $people.first_name$ you will get something like:
	# Alejandro\nPepe\nJuanito
	#
	# @var: 		the variable identifier. It is of the form $table.field.format$ where format is optional
	# @people:	the people whose data will be used to replace the variables in the text.
	def get_variable_values(var, people)
		people.map{ |person| get_variable_value(var, person)}.join("\n")
	end

	# replaces variables with the values corresponding to each person
	# @source: 	the source file content
	# @people:	the persons set whose data will be used to replace the variables in the text.
	def replace_variables_of_set(people)
		@variables.inject(@template_source){ |res, var| res.gsub!(var, get_variable_values(var,people)) }
	end


	# delete all files int the TYPST_TEMPLATES_DIR with suffixes .tmp.typ and .tmp.pdf
	def clean_tmp_files
		["typ","pdf"].each do |suffix|
			files = Dir.glob("#{TYPST_TEMPLATES_DIR}/*.tmp.#{suffix}")
			files.each {|file| File.delete file}
		end
	end

end #class end
