# document.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION
# A class defining a Document object.
# Each Document has an engine in charge of writing the document.
# -----------------------------------------------------------------------------------------

# requires the engines to produce the documents.
require_rel '../engines'

class Document < ActiveRecord::Base

	belongs_to 	    :pulpo_module

	validates 			:name, uniqueness: { message: "there is already another document with that name." }
	validates 			:path, presence: { message: "you need to provide a file template." }, on: :create

	# the default scoped defines the default sort order of the query results
	default_scope { order(pulpo_module_id: :asc, name: :asc) }

	EXCEL_TEMPLATES_DIR = "app/engines-templates/excel"
	TYPST_TEMPLATES_DIR = "app/engines-templates/typst"

	enum :engine,    {excel: 1, typst: 2}

	# -----------------------------------------------------------------------------------------
	# CALLBACKS
	# -----------------------------------------------------------------------------------------

  # if a document is destroyed then we delete the associated file stored in the corresponding
	# templates directory
	before_destroy do |doc|
		full_path = doc.get_full_path
		FileUtils.rm full_path if File.file? full_path
	end

	# -----------------------------------------------------------------------------------------
	# CRUD METHODS
	# -----------------------------------------------------------------------------------------

	def self.create(params)
		doc = super(Document.prepare_params params)

		# upddates the template file according to the new file received
		# by the form (in params[:template])
		if params[:template]!=nil
			doc.update_template_file(params[:template][:tempfile]) unless params[:template].nil?
			doc.template_variables = Document.has_template_variables?(File.read params[:template][:tempfile])
			doc.save
		end
		doc
	end

	def update(params)

		previous_path = get_full_path
		previous_name = name
		update_result = super(Document.prepare_params params)

		if(update_result)

			# the name of the template changed but no new file was provided. We just update the name of the current file
			if(params[:name]!=previous_name && params[:template].nil?)
				target = "#{TYPST_TEMPLATES_DIR}/#{name}.typ"
				FileUtils.mv previous_path, target if File.file?(previous_path)
			end

			# the name of the template did not change, but a new file was provided
			if(params[:template]!=nil)
				FileUtils.cp(params[:template][:tempfile], get_full_path)
				self.template_variables = Document.has_template_variables?(File.read params[:template][:tempfile])
				self.save
			end

		end

		update_result
	end

	def update_template_file(file)
			FileUtils.cp file, get_full_path
	end

	def get_full_path
		"#{TYPST_TEMPLATES_DIR}/#{path}"
	end

	def self.prepare_params(params)
		puts "got params"
		puts params
		file_suffix = "typ"
		hash = {
			pulpo_module_id:        params[:module],
			name:                   params[:name],
			description:            params[:description],
			engine:                 "typst",
			path: 									"#{params[:name]}.#{file_suffix}",
			singlepage:             (params[:singlepage].blank? ? true : params[:singlepage]=="true")
		}
	end

	def self.get_docs_of_user(user)
		Document.includes(:pulpo_module).where(pulpo_module: user.get_allowed_modules)
	end


	def get_attribute(table_attribute)
		case table_attribute.table
			when "documents" 			then self[table_attribute.field.to_sym]
			when "pulpo_modules" 	then pulpo_module[table_attribute.get_field_name.to_sym]
		end
	end

	def self.get_pdf_docs_of_user(user)
		Document.includes(:pulpoo_module).all.order(:pulpo_module_id, :name).select{|doc| ((user.get_allowed_modules.include? doc.pulpo_module) && doc.engine!="excel")}
	end

	def self.get_pdf_docs_of_modules(modules)
		Document.includes(:pulpo_module).where('pulpo_modules.id' => modules)
	end

	def get_writer(people, template_variables=nil)
		TypstWriter.new(self, people, template_variables)
	end

	# checks whether the source has template variables. Template variables are wrapped in double dolar signs
	# i.e. $$myvariable$$
	def self.has_template_variables?(source)
		#!source.scan(/\$\$\S*\$\$/).empty?
		#!source.scan(/\$\$\S*\$\$/).empty?
		puts "checking if file has template variables. returning #{!source.scan(/pulpo.\S*/).empty?}"
		!source.scan(/pulpo.\S*/).empty?
	end

	def has_template_variables?
		template_variables
	end

	def get_template_variables
		tv = File.read(get_full_path).scan(/pulpo.\S*/).map{ |var| var.gsub("pulpo.","").gsub("\"","")}
		puts "got template variables #{tv.inspect}"
		tv
	end

	def can_be_deleted?
		true
	end

	# validates the params received from the form.
	def self.validate(params)
		document = Document.new(Document.prepare_params params)
		{ result: document.valid?, message: ValidationErrorsDecorator.new(document.errors.to_hash).to_html }
	end

	# validates the params received from the form.
	def validate(params)
		puts "validating existing object"
		self.update(params)
		{ result: valid?, message: ValidationErrorsDecorator.new(errors.to_hash).to_html }
	end



end # class end
