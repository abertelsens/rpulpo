###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

# A class containing the Users data
class User < ActiveRecord::Base
	
	enum usertype: {normal: 0, admin: 1, guest: 2}

	has_many	:unread_mails, dependent: :destroy
	has_many	:assigned_mails, dependent: :destroy
	has_many	:assignedmails, :through => :assigned_mails, :source => :mail , dependent: :destroy
	has_many 	:module_users, dependent: :destroy
	

##########################################################################################
# STATIC METHODS
##########################################################################################
	
	def self.prepare_params(params)
	{
		uname: 			params[:uname], 
  	password: 	params[:password],
		usertype:		params[:usertype],
		mail:				!params[:mail].nil?
	}
	end

	# creates a user and updated the module permissions.
	def self.create_from_params(params)
    user = User.create User.prepare_params params
		PulpoModule.all.each {|mod| user.updatePermission(mod.id, params["module_#{mod.id}".to_sym]) }	
	end
	
	def self.get_all()
		User.order(uname: :asc)
	end


	######################################################################################################
  # CRUD METHODS
  ######################################################################################################

  def update_from_params(params)
		update User.prepare_params params
		PulpoModule.all.each{|mod| updatePermission(mod.id, params["module_#{mod.id}".to_sym])} 
	end

	# authenticates the user login data.
	def self.authenticate(uname,password)
		user = User.find_by(uname: uname)
		return false if user.nil?
		user.password==password ? user : false
  end


##########################################################################################
# PERMISSIONS
##########################################################################################

	# updates the module permission for module with module_id
	def updatePermission(module_id, permission)
		module_user = ModuleUser.find_by(user_id: self.id, pulpo_module_id: module_id)
		if module_user.nil?
			ModuleUser.create(user_id: self.id, pulpo_module_id: module_id, modulepermission: permission)
		else
			module_user.update(modulepermission: permission)
		end
	end

	# get the permission for a module
	def get_permission(mod)
		puts "asking permission of module #{mod} for user #{uname}"
		mu = module_users.find_by(pulpo_module: mod)
		mu.nil? ? nil : mu.modulepermission
	end

	def admin?
		self[:usertype]=="admin"
	end

	def get_allowed_modules
		return PulpoModule.all if self.admin? 		# an admin has all permitions.
		(module_users.select {|mu| mu.modulepermission=="allowed"}).map {|mu| mu.pulpo_module}
	end

	def allowed?(module_identifier)
		puts "asking if module #{module_identifier} is allowed. Found module #{PulpoModule.find_by(identifier: module_identifier)}"
		return true if admin?
		(get_permission PulpoModule.find_by(name: module_identifier))=="allowed"
	end

	def is_table_allowed?(table)
		return true if self.admin? 		# an admin has all permitions.
		settings = module_users.find_by(pulpo_module: PulpoModule.find_by(name: table))
		settings.nil? ? false : settings.modulepermission=="allowed"
	end

	# admini users can be deleted only if there is more than one. 
	def can_be_deleted?
		if self[:usertype]!="admin"
			return true 
		else
			return User.where(usertype: "admin").size() > 1
		end
	end

	# Validates the parametes from the user form. 
	# Checks whether there is already a user with the provided user name
	def self.validate(params)
		puts "Validating with params #{params}"
		
		# tries to find an existing user with the name provided.
		user  = User.find_by(uname: params[:uname])
		
		puts "found user with username #{params[:uname]}" unless user.nil?
		
		validation_result = user.nil? ? true : user.id==params[:id]
		validation_result ? {result: true} : {result: false, message: "user name already in use"}
	end


	def get_mails(args)
		case args	
			when :assigned 	then assignedmails.pluck(:mail)
			when :unread	then unreadmails.pluck(:mail)
		end
	end
end #class end