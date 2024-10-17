# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE MODULES TABLES
# -----------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# GET
# -----------------------------------------------------------------------------------------

get '/modules' do
	partial :"frame/modules"
end

get '/modules/table' do
	@table_settings = TableSettings.new(table: :pulpo_modules_default)
	@objects = PulpoModule.all
	partial :"table/simple_template"
end

get '/module/:id' do
	@object = (params[:id]=="new" ? nil : PulpoModule.find(params[:id]))
	partial :"form/module"
end

get '/pulpomodule/:id' do
	@object = (params[:id]=="new" ? nil : PulpoModule.find(params[:id]))
	partial :"form/module"
end

# -----------------------------------------------------------------------------------------
# POST ROUTES
# -----------------------------------------------------------------------------------------

# Returns a JSON object
post '/module/:id/validate' do
	content_type :json
	(PulpoModule.validate params).to_json
end

post '/module/:id' do
  pmodule = PulpoModule.find(params[:id]) unless params[:id]=="new"
	case params[:commit]
		when "save" then (pmodule==nil ? (PulpoModule.create params ): (pmodule.update params))
		when "delete" then pmodule.destroy
	end
  redirect '/modules'
end
