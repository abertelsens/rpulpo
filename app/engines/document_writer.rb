# -----------------------------------------------------------------------------------------
# DESCRIPTION
# An abstract class definign a writer. The only current use is to provide some error
# logging capabilities for all the classes that inherit from it.
# -----------------------------------------------------------------------------------------

class DocumentWriter

	attr_accessor :status, :message

	OK 			= 1
	WARNING = 2
	FATAL 	= 3

	def initialize(document, template_variables=nil)
		@status = OK
		@message = ""
		@document = document
		@template_variables = template_variables
		@decorator = PersonDecorator.new

		begin
			@template_source = File.read document.get_full_path
		rescue
			set_error(FATAL,"Template #{document.path} not foud in #{@template_file}.
			You should check the settings of #{document.name} file before trying again.")
			@status = FATAL
		end
		@template_source = replace_template_variables template_variables
	end

	def set_error(error, msg)
		@status = error
		@message = msg
	end

	def replace_template_variables(template_variables=nil)
		return @template_source unless template_variables
		template_variables.keys.each do |key|
			@template_source.gsub!("pulpo.#{key}",template_variables[key])
		end
		@template_source
	end

	def write()
		@template_source
	end

	def ready?()
		return status==OK
	end

end #class end
