# entities.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# author: alejandrobertelsen@gmail.com
# last major update: 2024-10-05
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# ROUTES CONTROLLERS FOR THE entities TABLE
#---------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------
# GET ROUTES
# --------------------------------------------------------------------------------------

require_rel '../decorators'

# renders the entities frame
get '/entities' do
	slim :"frame/simple_template",  locals: { title: "ENTITIES", model_name: "entity" }
end

# renders the table of entities
# @objects - the entities that will be shown in the table
get '/entities/table' do
	@table_settings = TableSettings.get :entities_default
	@objects = Entity.all
	@decorator = ObjectDecorator.new(table_settings: @table_settings)
	partial :"table/simple_template"
end

# renders a single entity form
get '/entity/:id' do
	@object = (params[:id]=="new" ? nil : Entity.find(params[:id]))
	slim :"form/entity"
end

# --------------------------------------------------------------------------------------
# POST ROUTES
# --------------------------------------------------------------------------------------

post '/entity/:id' do
	case params[:commit]
		when "new"		then	Entity.create params
		when "save" 	then 	Entity.find(params[:id]).update params
		when "delete" then 	Entity.find(params[:id]).destroy
	end
	redirect '/entities'
end

# Validates if the params received are valid for updating or creating an entity object.
# returns a JSON object of the form {result: boolean, message: string}
post '/entity/:id/validate' do
	content_type :json
	(new_id? ? (Entity.validate params) : (Entity.find(params[:id]).validate params)).to_json
end
