###########################################################################################
# DESCRIPTION
# A class defininign an entity.
###########################################################################################

class Entity < ActiveRecord::Base
	
	# enum usertype:    {normal: 0, admin: 1, guest: 2} 
	has_many :received_mails, class_name: "Mail", foreign_key: "from"
	has_many :sent_mails, class_name: "Mail", foreign_key: "to" 
	
	before_destroy do
		self.received_mails.each {|mail| mail.destroy}
		self.sent_mails.each {|mail| mail.destroy}
	end

##########################################################################################
# STATIC METHODS
##########################################################################################
	
	# transforms the parameters received from the form into a hash that can be used to create
	# a user object by the SaxumObject class 
	def self.prepare_params(params)
	{
		sigla: 	params[:sigla],
		name:	params[:name],
		path:	params[:path]
	}
	end

	# creates a user and updated the module permissions.
	def self.create_from_params(params)
		Entity.create(prepare_params params)
	end

	def update_from_params(params)
		update(Entity.prepare_params params)
	end
	
	def can_be_deleted?
		true
	end

	def self.get_all
		Entity.all - [Entity.find_by(sigla: "crs+")]
	end

end #class end