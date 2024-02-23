########################################################################################
# ROUTES CONTROLLERS FOR THE USERS TABLES
########################################################################################

########################################################################################
# GET ROUTES
########################################################################################

get '/entities' do
    @current_user = get_current_user
    partial :"frame/entities"
end

get '/entities/table' do
    @objects = Entity.all.order(name: :asc)
    partial :"table/entity"
end

get '/entity/:id' do
    @object = (params[:id]=="new" ? nil : Entity.find(params[:id]))
    partial :"form/entity"
end

# -----------------------------------------------------------------------------------------
# POST ROUTES
# -----------------------------------------------------------------------------------------

# Returns a JSON object
post '/entity/:id/validate' do
    content_type :json
    (Entity.validate params).to_json
  end


post '/entity/:id' do
    case params[:commit]
      when "save" then Entity.create_update params
      when "delete" then Entity.destroy params
    end
    redirect '/entities'
  end
