# -----------------------------------------------------------------------------------------
# DESCRIPTION
# A class defininign an entity object. I.e. a ctr we receive mail from or send mail to.
# -----------------------------------------------------------------------------------------

class Entity < ActiveRecord::Base

	has_many :mails,  dependent: :destroy

# -----------------------------------------------------------------------------------------
# CALLBACKS
# -----------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------
# CRUD METHODS
# -----------------------------------------------------------------------------------------

	def self.create(params)
		super(Entity.prepare_params params)
	end

	def update(params)
		super(Entity.prepare_params params)
	end

	def self.create_update(params)
		if params[:id]=="new"
			Entity.create(params)
		else
			Entity.find(params[:id]).update(params)
		end
	end

	# transforms the parameters received from the form into a hash that can be used to create
	# a user object by the SaxumObject class
	def self.prepare_params(params)
	{
		sigla: 	params[:sigla],
		name:		params[:name],
		path:		params[:path]
	}
	end

	def self.destroy(params)
		Entity.find(params[:id]).destroy
	end

	def can_be_deleted?
		true
	end

	def self.get_all
		Entity.all - [Entity.find_by(sigla: "crs+")]
	end

end #class end
