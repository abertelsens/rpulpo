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

	validates :sigla, uniqueness: { message: "ya hay otra entidad con esa sigla." }


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

	def update(params)
		super(Entity.prepare_params params)
	end

	def self.prepare_params(params)
		params.except!("id") if params["id"]=="new"
		params.select{|param| Entity.attribute_names.include? param}
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

	# validates the params received from the form.
	def self.validate(params)
		ent = Entity.new(Entity.prepare_params params)
		{ result: ent.valid?, message: ValidationErrorsDecorator.new(ent.errors.to_hash).to_html }
	end

	# validates the params received from the form.
	def validate(params)
		self.update(params)
		{ result: valid?, message: ValidationErrorsDecorator.new(errors.to_hash).to_html }
	end

end #class end
