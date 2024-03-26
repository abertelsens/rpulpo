# -----------------------------------------------------------------------------------------
# DESCRIPTION
# A class to produce pdf documents via Typst. See https://typst.app
# The class relies on the typst gem (https://github.com/actsasflinn/typst-rb)
# -----------------------------------------------------------------------------------------

require 'os'

# in case we are on a mac we run typst via the typs gem. In windows we are foreced to call
# the typst executable because the gem is not working (as of 11-02-2024)
require 'typst' if OS.mac?

class TypstWriter < DocumentWriter

	MONTHS_LATIN = [nil, "Ianuarius", "Februarius", "Martius", "Aprilis", "Maius", "Iunius", "Iulius", "Augustus", "September", "October", "November", "December"]

	# The directory where the typst templates are located.
	TYPST_TEMPLATES_DIR ="app/engines-templates/typst"

	def initialize(document, people, template_variables=nil)
		@status = true
		@error_msg = ""
		@document = document
		@people = people
		@template_source = File.read "#{TYPST_TEMPLATES_DIR}/#{@document.path}"

		if @template_source.nil?
			set_error(FATAL,"Template #{@document.path} not foud in #{TYPST_TEMPLATES_DIR}. You should check the settings of #{@document.name} file before trying again.")
			return
		end


		# stores an array of all the variables found in the template.
		template_variables.each {|var| @template_source.gsub!("$$#{var[0]}$$",var[1])} if template_variables
		@variables = @template_source.scan(/\$\S*\$/)

		# process each person.
		# replace the variables in the md file with the values retrieved from the DB
		if @document.singlepage
			@typst_src = replace_variables_of_set(@template_source,people)
		else
			@typst_src =(@people.map { |person| replace_variables(@template_source,person) }).join("\n")
		end

	end

	# replaces variables with the values corresponding to each person
	def replace_variables(source, person)
		variables = @variables.map{ |var| [var, get_variable_value(var,person)] }
		result = source
		variables.each {|var| var[1].nil? ? result = result.gsub(var[0], "NOT FOUND") : result = result.gsub(var[0],var[1].to_s) }
		return result
	end

		# replaces variables with the values corresponding to each person
		def replace_variables_of_set(source, people)
			variables = @variables.map{ |var| [var, get_variable_values(var,people)] }
			result = source
			variables.each {|var| var[1].nil? ? result = result.gsub(var[0], "NOT FOUND") : result = result.gsub(var[0],var[1]) }
			return result
		end

	def get_variable_value(var,person)
		# clean the $ characters and parse the variable.
		variable_identifier = var.gsub("$","")
		variable_array = variable_identifier.split(".")
		db_variable = !variable_array[1].nil?

		if db_variable
			person.get_attribute(variable_identifier, variable_array[2])
		else
			set_error WARNING, "Typst Writer: don't know how to replace '#{variable_identifier}'"
			return nil
		end
	end

	def get_variable_values(var,people)
		# clean the $ characters and parse the variable.
		variable_identifier = var.gsub("$","")
		variable_array = variable_identifier.split(".")
		db_variable = !(variable_identifier.split("."))[1].nil?

		if db_variable
			(people.map{ |person| person.get_attribute(variable_identifier)}).join(" \n")
		else
			set_error WARNING, "Typst Writer: don't know how to replace '#{variable_identifier}'"
			return nil
		end
	end

	def render(output_type="pdf")
		begin
			# if running in windows we will produce a file
			if OS.windows?
				# delete all the previous pdf files. Not ideal
				# write a tmp typst file and compile it to pdf
				FileUtils.rm Dir.glob("#{TYPST_TEMPLATES_DIR}/*.pdf")
				tmp_file_name ="#{rand(10000)}"
				typ_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.typ"
				pdf_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.pdf"

				File.write typ_file_path, @typst_src
				res =  system("typst compile --root ../.. #{typ_file_path} #{pdf_file_path}")
				File.delete typ_file_path
				res ? (return pdf_file_path) : set_error(FATAL, "Typst Writer: failed to convert document: #{error.message}")

			# if running in osx we produce the file via the typst gem
			else
				Typst::Pdf.from_s(@typst_src).document
			end
		rescue => error
				set_error(FATAL, "Typst Writer: failed to convert document: #{error.message}")
		end
	end

end #class end
