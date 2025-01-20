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

	def initialize(document)
		@status = OK
		@message = ""
		@document = document
		@decorator = PersonDecorator.new

		begin
			@template_source = File.read document.get_full_path
		rescue
			set_error(FATAL,"Template #{document.path} not foud in #{@template_file}.
			You should check the settings of #{document.name} file before trying again.")
			@status = FATAL
		end
	end

	def set_error(error, msg)
		@status = error
		@message = msg
	end

	def write(variables=nil)
		return @template_source unless variables

		@template_source.scan(/pulpo.\w*[.]*[\w\-\:()]*/).map do |var|
			v = var.split(".")
			@template_source.gsub!(var, variables[v[1]])
		end
		@template_source
	end

	def ready?()
		return status==OK
	end

end #class end
