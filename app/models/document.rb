# -----------------------------------------------------------------------------------------
# DESCRIPTION
# A class defining a Document object.
# Each Document has an engine in charge of writing the document.
# -----------------------------------------------------------------------------------------

# requires the engines to produce the documents.
require_rel '../engines'

class Document < ActiveRecord::Base

	belongs_to 	    :pulpo_module

	# the default scoped defines the default sort order of the query results
	default_scope { order(pulpo_module_id: :asc, name: :asc) }

	EXCEL_TEMPLATES_DIR = "app/engines-templates/excel"
	TYPST_TEMPLATES_DIR = "app/engines-templates/typst"

	enum engine:    {excel: 1, typst: 2}

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
		doc.update_template_file(params[:template][:tempfile]) unless params[:template].nil?
	end

	def update(params)
		# the name of the template change but no new file was provided. We just update the name of the current file
		# the file itself remains unchanged
		if(params[:name]!=name && params[:template].nil?)
			target = "#{TYPST_TEMPLATES_DIR}/#{params[:name]}.typ"
			FileUtils.mv get_full_path, target
		end
		res = super(Document.prepare_params params)
		update_template_file(params[:template][:tempfile]) unless params[:template].nil?
		return res
	end

	def update_template_file(file)
			FileUtils.cp file, get_full_path
	end

	def get_full_path
		"#{TYPST_TEMPLATES_DIR}/#{path}"
	end

	def self.prepare_params(params)
		file_suffix = "typ"
		if params[:template]!=nil
			template_variables = Document.has_template_variables?(File.read params[:template][:tempfile])
		end
		{
			pulpo_module_id:        params[:module],
			name:                   params[:name],
			description:            params[:description],
			engine:                 "typst",
			path:                   "#{params[:name]}.#{file_suffix}",
			singlepage:             (params[:singlepage].blank? ? true : params[:singlepage]=="true"),
			template_variables:     template_variables
		}
	end

	def self.get_docs_of_user(user)
		Document.includes(:pulpo_module).where(pulpo_module: user.get_allowed_modules)
	end

	def self.get_pdf_docs_of_user(user)
		Document.includes(:pulpo_module).all.order(:pulpo_module_id, :name).select{|doc| ((user.get_allowed_modules.include? doc.pulpo_module) && doc.engine!="excel")}
	end

	def get_writer(people, template_variables=nil)
		TypstWriter.new(self, people, template_variables)
	end

	# checks whether the source has template variables. Template variables are wrapped in double dolar signs
	# i.e. $$myvariable$$
	def self.has_template_variables?(source)
		!source.scan(/\$\$\S*\$\$/).empty?
	end

	def has_template_variables?
		template_variables
	end

	def get_template_variables
		File.read(get_full_path).scan(/\$\$\S*\$\$/).map{ |var| var.gsub("$$","")}
	end

	def can_be_deleted?
		true
	end

	def self.validate(params)
		warning_message = "Warning: there is already a document with that name."
		name = params[:name].strip
		found =
			if (params[:id])=="new"
				!Document.find_by(name: name).nil?
			else
				document = Document.find_by(name: name)
				document.nil? ? false : (document.id!=params[:id].to_i)
			end
		found ? {result: false, message: warning_message} : {result: true}
	end

end # class end