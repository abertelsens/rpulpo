# -----------------------------------------------------------------------------------------
# DESCRIPTION
# A class defininign a user object.
# -----------------------------------------------------------------------------------------

class User < ActiveRecord::Base

	enum usertype: {normal: 0, admin: 1, guest: 2}

	has_many	:unread_mails, dependent: :destroy
	has_many	:assigned_mails, dependent: :destroy
	has_many	:assignedmails, :through => :assigned_mails, :source => :mail , dependent: :destroy
	has_many 	:module_users, dependent: :destroy

# -----------------------------------------------------------------------------------------
# CALLBACKS
# -----------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------
# CRUD METHODS
# -----------------------------------------------------------------------------------------

	def self.create(params)
		user = super(User.prepare_params params)
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
		if params[:id]=="new"
			User.create(params)
		else
			User.find(params[:id]).update(params)
		end
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
	# ACCESSORS
	# -----------------------------------------------------------------------------------------

	def self.get_all()
		User.order(uname: :asc)
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

	# admini users can be deleted only if there is more than one.
	def can_be_deleted?
		return true if usertype!="admin"
		User.where(usertype: "admin").size() > 1
	end

	def get_mails(args)
		case args
			when :assigned 	then assignedmails.pluck(:mail)
			when :unread	then unreadmails.pluck(:mail)
		end
	end

	def self.get_mail_users
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

	def mail_user?
		mail
	end

	def get_allowed_modules
		return PulpoModule.all if self.admin? 		# an admin has all permitions.
		(module_users.select {|mu| mu.modulepermission=="allowed"}).map {|mu| mu.pulpo_module}
	end

	def allowed?(module_identifier)
		puts "checking if #{uname} is allowed to see #{module_identifier}"
		puts "got: #{get_permission PulpoModule.find_by(name: module_identifier)}"
		return true if admin?
		puts "#{uname} is not an admin"
		(get_permission PulpoModule.find_by(name: module_identifier))=="allowed"
	end

	def is_table_allowed?(table)
		return true if self.admin? 		# an admin has all permitions.
		settings = module_users.find_by(pulpo_module: PulpoModule.find_by(name: table))
		settings.nil? ? false : settings.modulepermission=="allowed"
	end


end #class end
