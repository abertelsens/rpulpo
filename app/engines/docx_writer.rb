
# docx_writer.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-11-24
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class to produce docx files.

#require 'docx'

class WordWriter  < DocumentWriter

EXCEL_TEMPLATES_DIR ="app/engines-templates/word"

	def initialize(references)
		@references = references
		@document_path = "#{EXCEL_TEMPLATES_DIR}/#{@document.path}"

		# writes the file if there is the template exists
		if (File.file? @document_path)
			write_excel if (parse_yaml @document_path)
		else
			set_error(FATAL,"ExcelWriter: Template #{@document.path} not foud in #{EXCEL_TEMPLATES_DIR}. You should check the settings of #{@document.name} file before trying again.")
		end
	end



	def render(output_type="docx")
		begin
			clean_tmp_files
			tmp_file_name = "#{rand(10000)}"
			tmp_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.tmp.docx"

			# write the tmp source file to the file system and call the typst comppiler
			File.write tmp_file_path, @typst_source

		rescue => error


		end
	end


end #class end
