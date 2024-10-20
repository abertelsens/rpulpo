
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
	has_many	:unread_mails, 		dependent: :destroy
	has_many	:assigned_mails, 	dependent: :destroy
	has_many 	:module_users, 		dependent: :destroy

	# enables the creation/update of the association model_users via attributes.
	# See the the prepare_params method.
	accepts_nested_attributes_for :module_users #, allow_destroy: true

	# the default scoped defines the default sort order of the query results
	default_scope { order(uname: :asc) }

	# an enum defining the type of user.
	enum usertype: {normal: 0, admin: 1, guest: 2}

	DEFAULT_ADMIN_ATTRIBUTES = {uname: "admin", password: "admni", usertype: "admin", mail: true}

# -----------------------------------------------------------------------------------------
# CRUD METHODS
# -----------------------------------------------------------------------------------------

	def self.create(params)
		super(User.prepare_params params)
	end

	def update(params)
		super(User.prepare_params(params, self))
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
		module_users_attributes:	User.prepare_modules_attributes(params["module"],user)
	}
	end

	# Prepares the form arguments for the creation or update of a user module permissions.
	# If called with no user then we assume we are creating and object, therefore the module_users parameters
	# will have no id.
	# @module_params: the form's parameters for the creation/update of permissions
	# @user: the current user, nil if we are creating it.
	# @returs: a hash that can be used to create/update the module_users association
	def self.prepare_modules_attributes(module_params, user=nil)
		if user!=nil
			current_modules = user.module_users.all.map {|mu| { mu.pulpomodule_id => mu.id } }
			current_modules = current_modules.inject(:merge)
			module_params.keys.map {|mod_id| {id: current_modules[mod_id.to_i], pulpomodule_id: mod_id, modulepermission: module_params[mod_id]} }
		else
			module_params.keys.map {|mod_id| { pulpomodule_id: mod_id, modulepermission: module_params[mod_id]} }
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


	# Validates the parameters from the user form.
	# Checks whether there is already a user with the provided user name
	def self.validate(params)

		# tries to find an existing user with the name provided.
		user  = User.find_by(uname: params[:uname])

		validation_result = user.nil? ? true : user.id==params[:id].to_i
		validation_result ? {result: true} : {result: false, message: "user name already in use"}
	end

# -----------------------------------------------------------------------------------------
# ACCSESSORS
# -----------------------------------------------------------------------------------------

	def self.ensure_admin_user
		User.create DEFAULT_ADMIN_ATTRIBUTES if User.admins.size<1
	end

	def self.mail_users
		User.where(mail:true)
	end

	# admin users can be deleted only if there is more than one.
	def can_be_deleted?
		admin? ? User.admins.size > 1 : true
	end

	def get_mails(args)
		case args
			when :assigned 	then assigned_mails.pluck(:mail_id)
			when :unread		then unread_mails.pluck(:mail_id)
		end
	end

	def admin?
		usertype=="admin"
	end

	def self.admins
		User.where(usertype: "admin")
	end

	def mail_user?
		mail
	end

	def get_allowed_modules
		return Pulpomodule.all if admin? 		# an admin has all permitions.
		(module_users.select {|mu| mu.modulepermission=="allowed"}).map {|mu| mu.pulpomodule}
	end

	def allowed?(module_identifier)
		return true if admin?
		result = (module_users.joins(:pulpomodule).where(pulpomodule: {name: module_identifier})).first
		return result.nil? ? false : result
	end

	def is_table_allowed?(table)
		return true if self.admin? 		# an admin has all permissions.
		settings = module_users.find_by(pulpomodule: Pulpomodule.find_by(name: table))
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
		mu = module_users.find_by(pulpomodule: mod)
		mu.nil? ? nil : mu.modulepermission
	end

	# get the permissions for all modules as a hash of the form {module_id => permission}
	# The inject method transforms an array of the permissions into a single hash.
	def get_permissions()
		(module_users.includes(:pulpomodule).map{|mu| {mu.pulpomodule.id => mu.modulepermission}}).inject(:merge)
	end

end #class end
