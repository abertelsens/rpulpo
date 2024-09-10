
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

	# the default scoped defines the default sort order of the query results
	default_scope { order(uname: :asc) }

	# an enum defining the type of user.
	enum usertype: {normal: 0, admin: 1, guest: 2}

# -----------------------------------------------------------------------------------------
# CRUD METHODS
# -----------------------------------------------------------------------------------------

	def self.create(params)
		# creates the user
		user = super(User.prepare_params params)

		# creates all the modules permissions for the user.
		if params["module"].present?
			modules = PulpoModule.find(params["module"].keys)
			module_users = modules.each do |mod|
				ModuleUser.create(user: user, pulpo_module: mod, modulepermission: params["module"][mod.id.to_s])
			end
		end
	end

	def update(params)
		super(User.prepare_params params)
		module_users.each{|mod| mod.update(modulepermission: params["module"][mod.pulpo_module_id.to_s])}
	end

	def self.create_update(params)
		params[:id]=="new" ? User.create(params) : User.find(params[:id]).update(params)
	end

	def self.destroy(params)
		User.find(params[:id]).destroy
	end

	def self.prepare_params(params)
	{
		uname: 			params[:uname],
  	password: 	params[:password],
		usertype:		params[:usertype],
		mail:				!params[:mail].nil?
	}
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
