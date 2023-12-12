###########################################################################################
# DESCRIPTION
# A class to produce pdf documents via Typst. See https://typst.app
# The class relies on the typst gem (https://github.com/actsasflinn/typst-rb)
###########################################################################################

require "typst"

class TypstWriter < DocumentWriter

    # The directory where the typst templates are located.
    TYPST_TEMPLATES_DIR ="app/engines-templates/typst"
    
    # Typst command to force a page break
    TYPST_PAGE_BREAK = "\n#pagebreak()\n"
    TYPST_PREAMBLE_SEPARATOR = "//CONTENTS"

    def initialize(document,people)
        @status = true
        @error_msg = ""
        @document = document    
        @people = people
        
        @template_source = File.read "#{TYPST_TEMPLATES_DIR}/#{@document.path}"
        
        if @template_source.nil? 
            set_error(FATAL,"Template #{@document.path} not foud in #{TYPST_TEMPLATES_DIR}. You should check the settings of #{@document.name} file before trying again.")
            return
        end
        
        # strores an array of all the variables found in the template.
        @variables = @template_source.scan(/\$\S*\$/)
        
        template_source = @template_source.split(TYPST_PREAMBLE_SEPARATOR)
        
        if template_source.size==1  #We could not find the TYPST_PREAMBLE_SEPARATOR in the file.
            set_error(FATAL,"Typst Writer: Could not find the //CONTENTS marker in template'#{@document.path}'. You should check the template source before trying again.")
            return
        else
            @template_preamble = template_source[0]
            @template_contents = template_source[1]
        end

        # process each person.
        # replace the variables in the md file with the values retrieved from the DB
        @typst_src = @template_preamble << (@people.map { |person| replace_variables(@template_contents,person) }).join(TYPST_PAGE_BREAK)
    end

    # replaces variables with the values corresponding to each person    
    def replace_variables(source,person)
        variables = @variables.map{ |var| [var, get_variable_value(var,person)] }
        variables.each {|var| source = var[1].nil? ? source.gsub(var[0], "NOT FOUND") : source.gsub(var[0],var[1]) }
        return source
    end

    def get_variable_value(var,person)
        # clean the $ characters and parse the variable.
        variable_identifier = var.gsub("$","")
        #puts Rainbow("Typst Writer: looking for variable: #{variable_identifier}").yellow
        variable_array = variable_identifier.split(".")
        db_variable = !variable_array[1].nil?
        if db_variable
            return person.get_attribute(variable_identifier)
        else
            set_error WARNING, "Typst Writer: don't know how to replace '#{variable_identifier}'"
            return nil
        end
    end

    def render(output_type="pdf")
        begin
            Typst::Pdf.from_s(@typst_src).document
        rescue => error
            set_error(FATAL, "Typst Writer: failed to convert document: #{error.message}")
        end
    end    

end #class end