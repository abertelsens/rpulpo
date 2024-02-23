# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE MODULES TABLES
# -----------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# GET
# -----------------------------------------------------------------------------------------

get '/modules' do
	@current_user = get_current_user
	partial :"frame/modules"
end

get '/modules/table' do
	@objects = PulpoModule.get_all
	partial :"table/modules"
end

# renders a single document view
get '/module/:id' do
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
  case params[:commit]
    when "save" then PulpoModule.create_update params
    when "delete" then PulpoModule.destroy params
  end
  redirect '/modules'
end
