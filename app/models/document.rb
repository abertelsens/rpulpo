###########################################################################################
# DESCRIPTION
# A class defining a Document object.
# Each Document has an engine in charge of writing the documetn. 	
###########################################################################################

# requires the engines to produce the documents.
require_rel '../engines'

class Document < ActiveRecord::Base

	EXCEL_TEMPLATES_DIR = "app/engines-templates/excel"
	TYPST_TEMPLATES_DIR = "app/engines-templates/typst"

	belongs_to 	    :pulpo_module
	enum engine:    {prawn: 0, excel:1, typst:2} 

  # if a document is destroyed then we delete the associated file stored in the corresponding templates directory
	before_destroy do |doc|
		if doc.engine!="prawn"
			full_path = doc.get_full_path
			FileUtils.rm full_path if File.file? full_path
    end
	end

	def self.create_from_params(params)
		doc = Document.create Document.prepare_params params
		# upddates the template file according to the new file received by the form (in params[:template])
		doc.update_template_file(params[:template][:tempfile], params[:template][:filename]) unless params[:template].nil?
	end
	
	def update_from_params(params)
		if params[:name]!=self.name     # the name of the template did not change
			if params[:template].nil?  		# no new file was provided. We just update the name of the current file
				target = case engine
					when "pandoc" then "#{PANDOC_TEMPLATES_DIR}/#{params[:name]}.md"
					when "excel"  then "#{EXCEL_TEMPLATES_DIR}/#{params[:name]}.yaml"
					when "typ"  	then "#{TYPST_TEMPLATES_DIR}/#{params[:name]}.typ"
				end
				FileUtils.mv get_full_path, target 
			end
		end
		res = update Document.prepare_params params
		update_template_file(params[:template][:tempfile], params[:template][:filename]) unless params[:template].nil?
		return res
	end

	def update_template_file(file, filename)
			FileUtils.cp(file, get_full_path)
	end

	def get_full_path
		case engine
			when "excel" then "#{EXCEL_TEMPLATES_DIR}/#{path}"
			when "typst" then "#{TYPST_TEMPLATES_DIR}/#{path}"
		end
	end

	def self.get_template_extension(engine)
		case engine
			when "excel" then "yaml"
			when "typst" then "typ"
		end
	end

	def self.prepare_params(params)
		file_suffix = Document.get_template_extension params[:engine]
		if params[:template]!=nil
			template_variables = if params[:engine]=="typst"
					Document.has_template_variables?(File.read params[:template][:tempfile])   
				else
					false
				end
		end
		{
				pulpo_module_id:        params[:module],
				name:                   params[:name],
				description:            params[:description],
				engine:                 params[:engine],
				path:                   (params[:engine].blank? ? "" : "#{params[:name]}.#{file_suffix}"),
				template_variables:     template_variables
		}        
	end

	def self.get_docs_of_user(user)	
		Document.includes(:pulpo_module).all.order(:pulpo_module_id).select{|doc| user.get_allowed_modules.include? doc.pulpo_module }        
	end

	def self.get_pdf_docs_of_user(user)	
		Document.includes(:pulpo_module).all.order(:pulpo_module_id).select{|doc| ((user.get_allowed_modules.include? doc.pulpo_module) && doc.engine!="excel")}        
	end

	def get_writer(people, template_variables=nil)
		case engine
			when "prawn" then PrawnWriter.new(self, people)
			when "excel" then ExcelWriter.new(self, people)
			when "typst" then TypstWriter.new(self, people, template_variables)
		end
	end

			
	def self.has_template_variables?(source)
			variables = source.scan(/\$\S*\$/)
			template_variables = variables.select { |var| var.gsub("$","").split(".")[1].nil? }
			!template_variables&.empty?
	end

	def has_template_variables?
			template_variables
	end

	def get_template_variables
			variables = File.read(get_full_path).scan(/\$\S*\$/)
			(variables.select { |var| var.gsub("$","").split(".")[1].nil? }).map{|var| var.gsub("$","")}
	end

end # class end