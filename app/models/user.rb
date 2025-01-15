
# user.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-24
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defining a user
# -----------------------------------------------------------------------------------------

class User < ActiveRecord::Base

	# the related tables have a destroy dependency, i.e. if a user is deleted then also
	# the matching mails tables as deleted as well.
	has_many	:unread_mails, 			dependent: :destroy
	has_many	:assigned_mails, 		dependent: :destroy
	has_many 	:module_users, 			dependent: :destroy
	has_many 	:pulpo_modules, 		:through => :module_users
	has_many 	:documents, 				:through => :pulpo_modules

	validates :uname, uniqueness: { message: "there is another user with that name." }
	validates :uname, presence: 	{ message: "user name cannot be empty." }

	# the default scoped defines the default sort order of the query results
	default_scope { order(uname: :asc) }

	scope :mail_users, -> {where(mail:true)}

	# an enum defining the type of user.
	enum :usertype, { normal: 0, admin: 1, guest: 2 }

	DEFAULT_ADMIN_ATTRIBUTES = {uname: "admin", password: "admin", usertype: "admin", mail: true}



# -----------------------------------------------------------------------------------------
# CRUD METHODS
# -----------------------------------------------------------------------------------------

	def self.create(params)
		user = super(User.prepare_params params)
		user.pulpo_module_ids = user.get_modules_ids params["module"]
	end

	def update(params)
		puts "updating with params #{User.prepare_params(params)}"
		super(User.prepare_params(params))
		self.pulpo_module_ids = get_modules_ids params["module"]
	end

	def self.destroy(params)
		User.find(params[:id]).destroy
	end

	def self.prepare_params(params)
		{
			uname: 										params[:uname],
			password: 								params[:password],
			usertype:									params[:usertype],
			mail:											params[:mail]!=nil,
		}
	end

	def get_modules_ids module_params
		module_params.keys.select{|key| module_params[key]=="allowed"}
	end

	# -----------------------------------------------------------------------------------------
	# VALIDATIONS
	# -----------------------------------------------------------------------------------------

	# authenticates the user login data.
	def self.authenticate(uname, password)
		user = User.find_by(uname: uname)
		if user.nil? && Person.find_by(email: uname)
			User.create(uname: uname, password: "", usertype: "guest")
			return User.authenticate(uname,"")
		end
		return false if user.nil?
		user.password==password ? user : false
	end

# -----------------------------------------------------------------------------------------
# ACCSESSORS
# -----------------------------------------------------------------------------------------

	def self.ensure_admin_user
		User.create DEFAULT_ADMIN_ATTRIBUTES if User.admin.size<1
	end

	# admin users can be deleted only if there is more than one.
	def can_be_deleted?
		admin? ? User.admin.size > 1 : true
	end

	def mail_user?
		mail
	end

	def get_allowed_modules
		admin? ? PulpoModule.all : pulpo_modules
	end

	# returs an array of the form [module, [documents]]
	def get_documents
		allowed_modules = get_allowed_modules
		allowed_docs = Document.where(pulpo_module: allowed_modules.pluck(:id))
		allowed_modules.map{|mod| [mod, allowed_docs.select{|doc| doc.pulpo_module_id==mod.id} ] }.select{|mod| !mod[1].empty?}
	end

	# returs a hash with the documents of the user of the form {module_name: documentsAssociation }
	def get_documents_of_module(module_identifier)
		PulpoModule.find_by(identifier: module_identifier).documents
	end

	def allowed?(module_identifier)
		return true if admin?
		pulpo_modules.find_by(identifier: module_identifier)!=nil
	end

	def is_table_allowed?(table)
		return true if self.admin? 		# an admin has all permissions.
		settings = module_users.find_by(pulpo_module: PulpoModule.find_by(name: table))
		settings.nil?
	end

	def to_s
		"user credentials: uname: #{uname} password:#{password}"
	end

	# -----------------------------------------------------------------------------------------
	# PERMISSIONS
	# -----------------------------------------------------------------------------------------

	# get the permission for a module
	def get_permission(mod)
		pulpo_modules.find(mod.id)!=nil
	end

	def get_permissions()
		pulpo_modules
	end


	# validates the params received from the form.
	def self.validate(params)
		user = User.new(User.prepare_params params)
		{ result: user.valid?, message: ValidationErrorsDecorator.new(user.errors.to_hash).to_html }
	end

	# validates the params received from the form.
	def validate(params)
		self.update params
		{ result: self.valid?, message: ValidationErrorsDecorator.new(self.errors.to_hash).to_html }
	end

end #class end
