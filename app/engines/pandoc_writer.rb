require 'pandoc-ruby'
require 'combine_pdf'


class Pandoc_Writer
    
    PANDOC_TEMPLATES_DIR ="app/engines-templates/pandoc"

    DEFAULT_TEX_TEMPLATE = "#{PANDOC_TEMPLATES_DIR}/simple_template.tex"
    PDF_ENGINE = 'xelatex'
    
    MONTHS_LATIN = ["Ianuarius", "Februarius", "Martius", "Aprilis", "Maius", "Iunius", "Iulius", "Augustus", "September", "October", "November", "December"]
    LATEX_IMPRESO = "\\AddToHookNext{shipout/background}{\\put(1cm,-1\\paperheight+1cm){\\smallfont{$impreso$}}}"
    LATEX_DATE = "\\begin{flushright}$date$\\end{flushright}"
    LATEX_PAGE_BREAK = "\\pagebreak"
    
    
    def initialize(document,people)
        @document = document
        @source = File.read "#{PANDOC_TEMPLATES_DIR}/#{@document.path}"
        @target_path = "#{PANDOC_TEMPLATES_DIR}/#{File.basename(@source, ".md")}.pdf"
        @people = people
    
        # scan the file contents for all variables of type $variable_name$
        @variables = @source.scan(/\$\S*\$/)
        
        # reads the yaml preamble of the file and its contents
        if (md = @source.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$\n?)/m))
            @contents = md.post_match
            @metadata = YAML.load(md[:metadata])
            @preamble = md.to_s
        end
        
        # if there is no template set in the yaml preamble we assign the default template    
        @template = (@metadata["template"].nil? ? DEFAULT_TEX_TEMPLATE : @metadata["template"]) 
    end

    
    # convert the file to a PDF
    def convert()
        
        # changes the source according to the variables present in the preamble. For example if the variable impreso
        # is present a latex command to print the impreso will be added to the source.
        pandoc_src = @preamble
        new_src = process_yaml_preamble(@contents) 
        
        # process each person.
        @people.each do |person| 
            # replace the variables in the md file with the values retrieved from the DB
            pandoc_src << "#{replace_variables(new_src,person)}\n#{LATEX_PAGE_BREAK}\n"
        end
        
        # write the file
        @pdf = PandocRuby.new(pandoc_src, "--pdf-engine=#{PDF_ENGINE} --template=#{@template}", :standalone).to_pdf
        @pdf
    end

    # processes the preamble variables making changes in the source accordingly.
    def process_yaml_preamble(text)
        text << LATEX_DATE.gsub("$date$",@metadata["date"]) + "\n" if @metadata["date"]
        text << LATEX_IMPRESO.gsub("$impreso$",@metadata["impreso"]) + "\n" if @metadata["impreso"]
        return text           
    end

    # replaces variables with the values corresponding to each person    
    def replace_variables(source,person)
        variables = @variables.map{ |var| [var, get_variable_value(var,person)] }
        variables.each {|var| source = var[1].nil? ? source.gsub(var[0],"NOT FOUND") : source.gsub(var[0],var[1]) }
        return source
    end

    def get_variable_value(var,person)
        # clean the $ characters and parse the variable.
        variable_identifier = var.gsub("$","")
        variable_array = variable_identifier.split(".")
        db_variable = !variable_array[1].nil?
        if db_variable
            return person.get_attribute(variable_identifier)
        else
            case var
                when "$latin_date$" then Pandoc_Writer.latin_date(Time.new.strftime("%Y-%m-%d"))
                else puts "PANDOC WRITER: don't know how to replace '#{variable_identifier}'"
            end
        end
    end

    def self.latin_date(date)
        date_array = date.to_s.split("-")
        return "Roma, #{date_array[2]} #{MONTHS_LATIN[date_array[1].to_i-1]} #{date_array[0]}"
    end

end #class end
