# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE MODULES TABLES
# -----------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# GET
# -----------------------------------------------------------------------------------------

get '/pulpomodules' do
	partial :"frame/simple_template",  locals: {title: "MODULES", model_name: "pulpomodule", table_name: "pulpomodules" }
end

get '/pulpomodules/table' do
	@table_settings = TableSettings.new(table: :pulpomodules_default)
	@objects = Pulpomodule.all
	partial :"table/simple_template"
end

get '/pulpomodule/:id' do
	@object = (params[:id]=="new" ? nil : Pulpomodule.find(params[:id]))
	partial :"form/module"
end

get '/pulpomodule/:id' do
	@object = (params[:id]=="new" ? nil : Pulpomodule.find(params[:id]))
	partial :"form/module"
end

# -----------------------------------------------------------------------------------------
# POST ROUTES
# -----------------------------------------------------------------------------------------

# Returns a JSON object
post '/pulpomodule/:id/validate' do
	content_type :json
	(Pulpomodule.validate params).to_json
end

post '/pulpomodule/:id' do
  pmodule = Pulpomodule.find(params[:id]) unless params[:id]=="new"
	case params[:commit]
		when "save" then (pmodule==nil ? (Pulpomodule.create params ): (pmodule.update params))
		when "delete" then pmodule.destroy
	end
  redirect '/pulpomodules'
end
