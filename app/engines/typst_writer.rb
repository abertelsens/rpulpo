
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

	def initialize(document)
		super(document)
	end

	def render(data)
		TypstRuby.new.compile(data)
	end



end #class end
