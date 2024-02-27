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

	def set_error(error, msg)
		@status = error
		@message = msg
	end

end #class end
