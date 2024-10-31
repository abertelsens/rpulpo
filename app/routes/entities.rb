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

# renders the entities frame
get '/entities' do
	partial :"frame/simple_template",  locals: {title: "ENTITIES", model_name: "entity"}
end

# renders the table of entities
# @objects - the entities that will be shown in the table
get '/entities/table' do
	@table_settings = TableSettings.get(:entities_default)
	@objects = Entity.all
	partial :"table/simple_template"
end

# renders a single entity form
get '/entity/:id' do
	@object = (params[:id]=="new" ? nil : Entity.find(params[:id]))
	partial :"form/entity"
end

# --------------------------------------------------------------------------------------
# POST ROUTES
# --------------------------------------------------------------------------------------

post '/entity/:id' do
	#puts Rainbow("posting entity").orange
	entity = Entity.find(params[:id]) unless params[:id]=="new"
	case params[:commit]
		when "save" 	then (entity==nil ? (Entity.create params ): (entity.update params))
		when "delete" then entity.destroy
	end
	redirect '/entities'
end

# Validates if the params received are valid for updating or creating an entity object.
# returns a JSON object of the form {result: boolean, message: string}
post '/entity/:id/validate' do
	content_type :json
	(Entity.validate params).to_json
end
