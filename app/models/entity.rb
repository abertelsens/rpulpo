# entity.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-10-05
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defining an entity object. i.e. a ctr we receive mail from or send mail to.
#---------------------------------------------------------------------------------------

class Entity < ActiveRecord::Base

	has_many :mails,  dependent: :destroy

	# the default scoped defines the default sort order of the query results
	default_scope { order(sigla: :asc) }

	CRSC = "crs+"
	PARAMS = ["sigla", "name", "path"]

# -----------------------------------------------------------------------------------------
# CRUD METHODS
# -----------------------------------------------------------------------------------------

	def self.create(params)
		super(Entity.prepare_params params)
	end

	def self.prepare_params(params)
		params.select{ |key,val| PARAMS.include? key }
	end

	def update(params)
		super(Entity.prepare_params params)
	end

	def self.get_all
		Entity.where.not(sigla: CRSC)
	end

	def can_be_deleted?
		true
	end

	def number_of_mails
		mails.all.count
	end


	def self.validate(params)
		warning_message = "Warning: there is already an entity with that name."
		sigla = params[:sigla].strip
		found =
			if (params[:id])=="new"
				!Entity.find_by(sigla: sigla).nil?
			else
				entity = Entity.find_by(sigla: sigla)
				entity.nil? ? false : (entity.id!=params[:id].to_i)
			end
		found ? {result: false, message: warning_message} : {result: true}
	end

end #class end
