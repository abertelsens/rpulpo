# -----------------------------------------------------------------------------------------
# DESCRIPTION
# A class defininign an entity object. I.e. a ctr we receive mail from or send mail to.
# -----------------------------------------------------------------------------------------

class Entity < ActiveRecord::Base

	has_many :mails,  dependent: :destroy

	CRSC = "crs+"
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
		params[:id]=="new" ? Entity.create(params) : Entity.find(params[:id]).update(params)
	end

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
		Entity.where.not(sigla: CRSC)
	end

end #class end
