###########################################################################################
# DESCRIPTION
# A class defininign a Document object.
###########################################################################################

require_rel '../engines'

#A class containing the Users data
class Document < ActiveRecord::Base

    PANDOC_TEMPLATES_DIR = "app/engines-templates/pandoc"
    EXCEL_TEMPLATES_DIR = "app/engines-templates/excel"

    belongs_to 	    :pulpo_module    
    enum engine:    {pandoc: 0, prawn: 1, excel:2, typst:3} 

    # if a set is destroyed all the related records in the personsets are destroyed
	before_destroy do |doc|
        full_path = doc.get_full_path
        FileUtils.rm full_path if File.file? full_path
    end

    # if a set is destroyed all the related records in the personsets are destroyed
	before_save do |doc|
        
    end

    def self.create_from_params(params)
        doc = Document.create Document.prepare_params params
        doc.update_template_file(params[:template][:tempfile], params[:template][:filename]) unless params[:template].nil?
    end
    
    def update_from_params(params)
        if params[:name]!=self.name     #the name of the template did not change
            puts "\n\n\n\nname of the template changed"
            if params[:template].nil?  #no new file was provided. We change the name of the current file
                case engine
                    when "pandoc"  then FileUtils.mv self.get_full_path, "#{PANDOC_TEMPLATES_DIR}/#{params[:name]}.md"
                    when "excel"  then FileUtils.mv self.get_full_path, "#{EXCEL_TEMPLATES_DIR}/#{params[:name]}.yaml"
                end
            end
        end
        res = update Document.prepare_params params
        self.update_template_file(params[:template][:tempfile], params[:template][:filename]) unless params[:template].nil?
        return res
    end

    def update_template_file(file, filename)
        puts "full path: #{get_full_path}"
        FileUtils.cp(file, get_full_path)
    end

    def self.prepare_params(params)
        case params[:engine]
            when "pandoc" then file_suffix = "md"
            when "excel" then file_suffix = "yaml"
            when "typst" then file_suffix = "typ"
            end
            if params[:template]!=nil
                if params[:engine]=="typst" || params[:engine]=="pandoc"
                template_variables = has_template_variables?(File.read params[:template][:tempfile])    
                else
                    template_variables = false
                end
            end
        
        {
            pulpo_module_id:        params[:module],
            name:                   params[:name],
            description:            params[:description],
            engine:                 params[:engine],
            path:                   "#{params[:name]}.#{file_suffix}",
            template_variables:     template_variables
        }

        
    end

    def self.get_docs_of_user(user)
        Document.includes(:pulpo_module).all.order(:pulpo_module_id).select{|doc| user.get_allowed_modules.include? doc.pulpo_module }        
    end

    def get_full_path
        case engine
            when "pandoc" then "#{PANDOC_TEMPLATES_DIR}/#{self.name}.md"
            when "excel" then "#{EXCEL_TEMPLATES_DIR}/#{self.name}.yaml"
            else "unknown engine"
        end
    end
    
    def get_writer(people, template_variables=nil)
        puts "found engine #{engine} with path #{path}"
        writer = case engine
            when "pandoc" then Pandoc_Writer.new(self, people)
            when "prawn" then PrawnWriter.new(self, people)
            when "excel" then ExcelWriter.new(self, people)
            when "typst" then TypstWriter.new(self, people, template_variables)
        end
    end

        
    def self.has_template_variables?(source)
        variables = source.scan(/\$\S*\$/)
        puts "looking for template variables. Got #{variables.select { |var| var.gsub("$","").split(".")[1].nil? }}"
        puts "looking source: #{source}"
        template_variables = variables.select { |var| var.gsub("$","").split(".")[1].nil? }
        return !template_variables&.empty?
    end

    def has_template_variables?
        
        puts "asking for template variables of #{self.name}. Returning #{self.template_variables}"
        return self.template_variables
    end

    def get_template_variables
        variables = get_template_source().scan(/\$\S*\$/)
        (variables.select { |var| var.gsub("$","").split(".")[1].nil? }).map{|var| var.gsub("$","")}
    end

    def get_template_source
        case engine
            when "pandoc" then File.read("#{Pandoc_Writer::PANDOC_TEMPLATES_DIR}/#{self.path}")
            when "typst" then File.read("#{TypstWriter::TYPST_TEMPLATES_DIR}/#{self.path}")
        end
    end
end