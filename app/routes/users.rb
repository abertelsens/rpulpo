# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE USERS TABLES
# -----------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# GET
# -----------------------------------------------------------------------------------------

# renders the users frame
get '/users' do
    @current_user = get_current_user
    partial :"frame/users"
end

# renders the users table
get '/users/table' do
    @objects = User.all
    partial :"table/user"
end

# renders a user form
get '/user/:id' do
    @object = (params[:id]=="new" ? nil : User.find(params[:id]))
    partial :"form/user"
end

# -----------------------------------------------------------------------------------------
# POST ROUTES
# -----------------------------------------------------------------------------------------

# Returns a JSON object
post '/user/:id/validate' do
  content_type :json
  (User.validate params).to_json
end

post '/user/:id' do
  case params[:commit]
    when "save" then User.create_update params
    when "delete" then User.destroy params
  end
  redirect '/users'
end
