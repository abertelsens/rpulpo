# pulpo_modules.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# author: alejandrobertelsen@gmail.com
# last major update: 2024-10-30
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# ROUTES CONTROLLERS FOR THE PULPO MODULES TABLE
#---------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------
# GET ROUTES
# --------------------------------------------------------------------------------------

get '/pulpo_modules' do
	partial :"frame/simple_template",  locals: {title: "MODULES", model_name: "pulpo_module"}
end

get '/pulpo_modules/table' do
	@table_settings = TableSettings.get(:pulpo_modules_default)
	@objects = PulpoModule.all
	@decorator = ObjectDecorator.new(table_settings: @table_settings)
	partial :"table/simple_template"
end

get '/pulpo_module/:id' do
	@object = (params[:id]=="new" ? nil : PulpoModule.find(params[:id]))
	partial :"form/pulpo_module"
end

get '/pulpo_module/:id' do
	@object = (params[:id]=="new" ? nil : PulpoModule.find(params[:id]))
	partial :"form/pulpo_module"
end

# -----------------------------------------------------------------------------------------
# POST ROUTES
# -----------------------------------------------------------------------------------------

# Validates if the params received are valid for updating or creating an entity object.
# returns a JSON object of the form {result: boolean, message: string}
post '/pulpo_module/:id/validate' do
	content_type :json
	(new_id? ? (PulpoModule.validate params) : (PulpoModule.find(params[:id]).validate params)).to_json
end

post '/pulpo_module/:id' do
	case params[:commit]
		when "new"		then	PulpoModule.create params
		when "save" 	then 	PulpoModule.find(params[:id]).update params
		when "delete" then 	PulpoModule.find(params[:id]).destroy
	end
  redirect '/pulpo_modules'
end
