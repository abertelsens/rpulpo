# document.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION
# A class defining a Document object.
# -----------------------------------------------------------------------------------------

# requires the engines to produce the documents.
require_rel '../engines'

class Document < ActiveRecord::Base

	belongs_to 	    :pulpo_module

	validates 			:name, uniqueness: 	{ message: "there is already another document with that name." }
	validates 			:path, presence: 		{ message: "you need to provide a file template." }, on: :create

	# the default scoped defines the default sort order of the query results
	default_scope { order(pulpo_module_id: :asc, name: :asc) }

	TYPST_TEMPLATES_DIR = "app/engines-templates/typst"
	PRAWN_TEMPLATES_DIR = "app/views/prawn"

	SUFFIXES = {"typst" => "typ", "prawn" => "prawn"}
	TEMPLATES_DIR = {"typst" => TYPST_TEMPLATES_DIR, "prawn" => PRAWN_TEMPLATES_DIR}

	enum :engine,    {prawn: 1, typst: 2}

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
				target = "#{TEMPLATES_DIR[params[:engine]]}/#{name}.#{SUFFIXES[params[:engine]]}"
				FileUtils.mv previous_path, target if File.file?(previous_path)
			end

			# the name of the template did not change, but a new file was provided
			FileUtils.cp(params[:template][:tempfile], get_full_path) if(params[:template]!=nil)
		end

		update_result
	end

	def update_template_file(file)
		#puts "cp #{file} #{get_full_path}"
		FileUtils.cp file, get_full_path
	end

	def get_full_path
		case engine
		when "typst" then "#{TYPST_TEMPLATES_DIR}/#{path}"
		when "prawn" then "#{PRAWN_TEMPLATES_DIR}/#{path}"
		end
	end

	def get_doc_file_name
		path.split(".")[0]
	end


	def self.prepare_params(params)
		{
			pulpo_module_id:        params[:module],
			name:                   params[:name],
			description:            params[:description],
			engine:                 params[:engine],
			path: 									"#{params[:name]}.#{SUFFIXES[params[:engine]]}",
			singlepage:             (params[:singlepage].blank? ? true : params[:singlepage]=="true")
		}
	end


	# checks whether the source has template variables. Template variables are wrapped in double dolar signs
	# i.e. $$myvariable$$
	def self.has_template_variables?(source)
		#puts "checking if file has template variables. returning #{!source.scan(/pulpo.\w*/).empty?}"
		!source.scan(/pulpo.\S*/).empty?
	end

	def has_template_variables?
		Document.has_template_variables?(File.read get_full_path)
	end

	def get_template_variables
		#File.read(get_full_path).scan(/pulpo.\w*/).map{ |var| var.gsub("pulpo.","")}
		File.read(get_full_path).scan(/pulpo.\w*[.]*[\w\-\:()]*/).map do |var|
			#puts "fournd var #{var}"
			a = var.split(".")
			[a[1],a[2]]
		end
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
