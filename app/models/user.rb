
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

	validates :uname, uniqueness: { message: "there is another user with that name." }
	validates :uname, presence: 	{ message: "user name cannot be empty." }

	# the default scoped defines the default sort order of the query results
	default_scope { order(uname: :asc) }

	scope :mail_users, -> {where(mail:true)}

	# an enum defining the type of user.
	enum usertype: {normal: 0, admin: 1, guest: 2}

	DEFAULT_ADMIN_ATTRIBUTES = {uname: "admin", password: "admni", usertype: "admin", mail: true}

# -----------------------------------------------------------------------------------------
# CRUD METHODS
# -----------------------------------------------------------------------------------------

	def self.create(params)
		user = super(User.prepare_params params)
		user.pulpo_module_ids = params["module"].keys.select{|key| params["module"][key]=="allowed"}
	end

	def update(params)
		#puts "parameters to update #{User.prepare_params(params, self)}"
		super(User.prepare_params(params, self))
		self.pulpo_module_ids = params["module"].keys.select{|key| params["module"][key]=="allowed"}
		save
	end

	def self.destroy(params)
		User.find(params[:id]).destroy
	end

	def self.prepare_params(params, user=nil)
	{
		uname: 										params[:uname],
  	password: 								params[:password],
		usertype:									params[:usertype],
		mail:											!params[:mail].nil?,
		#module_users_attributes:	User.prepare_modules_attributes(params["module"],user)
	}
	end

	# Prepares the form arguments for the creation or update of a user module permissions.
	# If called with no user then we assume we are creating and object, therefore the module_users parameters
	# will have no id.
	# @module_params: the form's parameters for the creation/update of permissions
	# @user: the current user, nil if we are creating it.
	# @returs: a hash that can be used to create/update the module_users association
	def self.prepare_modules_attributes(module_params, user=nil)
		if user
			current_modules = (user.module_users.map {|mu| { mu.pulpo_module_id => mu.id } }).inject(:merge)
			module_params.keys.map {|mod_id| {id: current_modules[mod_id.to_i], pulpo_module_id: mod_id, modulepermission: module_params[mod_id]} }
		else
			module_params.keys.map {|mod_id| { pulpo_module_id: mod_id, modulepermission: module_params[mod_id]} }
		end
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
		return PulpoModule.all if admin? 		# an admin has all permitions.
		pulpo_modules
		#(module_users.select {|mu| mu.modulepermission=="allowed"}).map {|mu| mu.pulpo_module}
	end

	# returs a hash with the documents of the user of the form {module_name: documentsAssociation }
	def get_documents
		get_allowed_modules.map{|mod| [mod , mod.documents] }.select{|item| !item[1].empty?}
	end

	def allowed?(module_identifier)
		return true if admin?
		#puts "ckecking if #{uname} is allowed on #{module_identifier} #{pulpo_modules.find_by(identifier: module_identifier)!=nil}"
		pulpo_modules.find_by(identifier: module_identifier)!=nil
		#result = (module_users.joins(:pulpo_module).where(pulpo_module: {name: module_identifier})).first
		#return result.nil? ? false : result
	end

	def is_table_allowed?(table)
		return true if self.admin? 		# an admin has all permissions.
		settings = module_users.find_by(pulpo_module: PulpoModule.find_by(name: table))
		settings.nil? ? false : settings.modulepermission=="allowed"
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
		#mu = module_users.find_by(pulpo_module: mod)
		#mu.nil? ? nil : mu.modulepermission
	end

	# get the permissions for all modules as a hash of the form {module_id => permission}
	# The inject method transforms an array of the permissions into a single hash.
	def get_permissions()
		pulpo_modules
		#(module_users.includes(:pulpo_module).map{|mu| {mu.pulpo_module.id => mu.modulepermission}}).inject(:merge)
	end


	# validates the params received from the form.
	def self.validate(params)
		user = User.new(User.prepare_params params)
		{ result: user.valid?, message: ValidationErrorsDecorator.new(user.errors.to_hash).to_html }
	end

	# validates the params received from the form.
	def validate(params)
		self.update(params)
		{ result: self.valid?, message: ValidationErrorsDecorator.new(self.errors.to_hash).to_html }
	end

end #class end
