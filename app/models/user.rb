
# user.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defining a user
# -----------------------------------------------------------------------------------------

class User < ActiveRecord::Base

	# the related tables have a destroy dependency, i.e. if a user is deleted then also
	# the matching mails tables as deleted as well.
	has_many	:unread_mails, dependent: :destroy
	has_many	:assigned_mails, dependent: :destroy
	has_many	:assignedmails, :through => :assigned_mails, :source => :mail , dependent: :destroy
	has_many 	:module_users, dependent: :destroy

	accepts_nested_attributes_for :module_users #, allow_destroy: true


	# the default scoped defines the default sort order of the query results
	default_scope { order(uname: :asc) }

	# an enum defining the type of user.
	enum usertype: {normal: 0, admin: 1, guest: 2}

# -----------------------------------------------------------------------------------------
# CRUD METHODS
# -----------------------------------------------------------------------------------------

	def self.create(params)
		user = super(User.prepare_params params)
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

	def update_modules(modules_hash)
		modules = PulpoModule.find(modules_hash.keys)
		module_users = modules.each do |mod|
			ModuleUser.create(user: self, pulpo_module: mod, modulepermission: modules_hash[mod.id.to_s])
		end
	end

	def self.prepare_modules_attributes(module_params, user=nil)
		if user!=nil
			current_modules = user.module_users.all.map {|mu| { mu.pulpo_module_id => mu.id } }
			current_modules = current_modules.inject(:merge)
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

	# admin users can be deleted only if there is more than one.
	def can_be_deleted?
		admin? ? admins.size() > 1 : true
	end

	def get_mails(args)
		case args
			when :assigned 	then assignedmails.pluck(:mail)
			when :unread		then unreadmails.pluck(:mail)
		end
	end

	def self.mail_users
		User.where(mail:true)
	end

	# -----------------------------------------------------------------------------------------
	# PERMISSIONS
	# -----------------------------------------------------------------------------------------

	# get the permission for a module
	def get_permission(mod)
		mu = module_users.find_by(pulpo_module: mod)
		mu.nil? ? nil : mu.modulepermission
	end

	def admin?
		usertype=="admin"
	end

	def admins
		User.where(usertype: "admin")
	end

	def mail_user?
		mail
	end

	def get_allowed_modules
		return PulpoModule.all if admin? 		# an admin has all permitions.
		(module_users.select {|mu| mu.modulepermission=="allowed"}).map {|mu| mu.pulpo_module}
	end

	def allowed?(module_identifier)
		return true if admin?
		(get_permission PulpoModule.find_by(name: module_identifier))=="allowed"
	end

	def is_table_allowed?(table)
		return true if self.admin? 		# an admin has all permitions.
		settings = module_users.find_by(pulpo_module: PulpoModule.find_by(name: table))
		settings.nil? ? false : settings.modulepermission=="allowed"
	end

end #class end
