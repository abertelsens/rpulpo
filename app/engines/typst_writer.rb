
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
	TYPST_PAGE_BREAK = "\n#pagebreak()\n"
	TYPYT_PREAMBLE_END = "PULPO_TEXT"

	def initialize(document, template_variables=nil)
		super(document,template_variables)
		@variables = @template_source.scan(/\$\S*\$/)
	end

	def render(people)
		# process each person.
		# replace the variables in the md file with the values retrieved from the DB
		document_preamble, document_text = @template_source.split("PULPO_TEXT")
		@template_source = if @document.singlepage
			document_preamble << replace_variables_of_set(people, document_text)
		else
			document_preamble << (people.map { |person| replace_variables(person, document_text) }).join(TYPST_PAGE_BREAK)
		end

		begin
			clean_tmp_files

			tmp_file_name = "#{rand(10000)}"
			typ_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.tmp.typ"
			pdf_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.tmp.pdf"

			@typst_source = @message if @status==DocumentWriter::FATAL

			# write the tmp source file to the file system and call the typst comppiler
			File.write typ_file_path, @template_source
			res =  system("typst compile --root ../.. #{typ_file_path} #{pdf_file_path}")
			res ? (return pdf_file_path) : set_error(FATAL, "Typst Writer: failed to convert document: #{error.message}")

		rescue => error
			set_error(FATAL, "Typst Writer: failed to convert document: #{error.message}")
		end
	end

	# replaces variables with the values corresponding to each person
	# @source: 	the source file content
	# @person:	the person whose data will be used to replace the variables in the text.
	def replace_variables(person, source)
		@variables.inject(source) {|res, var| res.gsub(var, get_variable_value(var, person)) }
	end

	# gets the value of a variable for a specific person
	# @var: 		the variable identifier. It is of the form $table.field.format$ where format is optional
	# @person:	the person whose data will be used to replace the variables in the text.
	def get_variable_value(var, person)
		# clean the $ characters and parse the variable identifier.
		table, field, format = var.gsub("$","").split(".")
		@decorator.typst_value(person, "#{table}.#{field}", format)
	end

	# replaces variables with the values corresponding to each person
	# @people:	the persons set whose data will be used to replace the variables in the text.
	def replace_variables_of_set(people, source)
		@variables.inject(source){ |res, var| res.gsub!(var, get_variable_values(var,people)) }
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


	# delete all files int the TYPST_TEMPLATES_DIR with suffixes .tmp.typ and .tmp.pdf
	def clean_tmp_files
		["typ","pdf"].each do |suffix|
			files = Dir.glob("#{TYPST_TEMPLATES_DIR}/*.tmp.#{suffix}")
			files.each {|file| File.delete file}
		end
	end

end #class end
