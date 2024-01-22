###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

#A class containing the Users data
class User < ActiveRecord::Base
	
	enum usertype:    {normal: 0, admin: 1, guest: 2} 

##########################################################################################
# STATIC METHODS
##########################################################################################
	
	# transforms the parameters received from the form into a hash that can be used to create
	# a user object by the SaxumObject class 
	def self.params2hash(params)
	{
		uname: 			params[:uname], 
  		password: 	params[:password],
		usertype:		params[:usertype],
	}
	end

	# creates a user and updated the module permissions.
	def self.create_from_params(params)
    user = User.create User.params2hash params
		PulpoModule.all.each {|mod| user.updatePermission(mod.id, params["module_#{mod.id}".to_sym]) }	
	end
	
	

	#get all users
	def self.get_all()
		User.order(uname: :asc)
	end


	######################################################################################################
    # CRUD METHODS
    ######################################################################################################

    def update_from_params(params)
		params.delete("commit")
		self.update User.params2hash params
		PulpoModule.all.each do |mod| 
			updatePermission(mod.id, params["module_#{mod.id}".to_sym])
		end
	end

    def delete
        self.destroy
    end

	# authenticas the user login data.
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
	mu = ModuleUser.find_by(user:self, pulpo_module: mod)
	mu.nil? ? nil : mu.modulepermission
end

def admin?
	self[:usertype]=="admin"
end

def get_allowed_modules
	return PulpoModule.all if self.admin? 		# an admin has all permitions.
	(ModuleUser.where(user:self).select {|mu| mu.modulepermission=="allowed"}).map {|mu| mu.pulpo_module}
end

def allowed?(module_name)
	puts "asking permission of module #{module_name} for #{uname}"
	return true if admin?
	puts "got module ---#{get_permission PulpoModule.find_by(name: module_name)}---"
	(get_permission PulpoModule.find_by(name: module_name))=="allowed"
end

def is_table_allowed?(table)
	mod = PulpoModule.find_by(name: table)
	modser = ModuleUser.find_by(user:self, pulpo_module: PulpoModule.find_by(name: table))
	settings = ModuleUser.find_by(user:self, pulpo_module: PulpoModule.find_by(name: table)) 
	settings.nil? ? "forbidden" : ModuleUser.find_by(user:self, pulpo_module: PulpoModule.find_by(name: table)).modulepermission=="allowed"
end

# admini users can be deleted only if there is more than one. 
def can_be_deleted?
	puts "got user type #{self[:usertype]}"
	if self[:usertype]!="admin"
		return true 
	else
		puts "got adminis #{User.where(usertype: "normal").size()}"
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
end #class end