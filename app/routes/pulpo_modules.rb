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

# Returns a JSON object
post '/pulpo_module/:id/validate' do
	content_type :json
	(PulpoModule.validate params).to_json
end

post '/pulpo_module/:id' do
  pmodule = PulpoModule.find(params[:id]) unless params[:id]=="new"
	case params[:commit]
		when "save" then (pmodule==nil ? (PulpoModule.create params ): (pmodule.update params))
		when "delete" then pmodule.destroy
	end
  redirect '/pulpo_modules'
end
