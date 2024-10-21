# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE USERS TABLES
# -----------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# GET
# -----------------------------------------------------------------------------------------

# renders the users frame
get '/users' do
    @current_user = get_current_user
    partial :"frame/simple_template",  locals: {title: "USERS", model_name: "user", table_name: "users" }
end

# renders the users table
get '/users/table' do
  @table_settings = TableSettings.new(table: :users_default)
  @objects = User.all
  partial :"table/simple_template"
end

# renders a user form
get '/user/:id' do
    @object = (params[:id]=="new" ? nil : User.find(params[:id]))
    # get a has with the permissions of the user
    @permissions = @object.get_permissions if @object
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
  user = User.find(params[:id]) unless params[:id]=="new"
  case params[:commit]
    when "save" then (user==nil ? (User.create params ): (user.update params))
    when "delete" then user.destroy
  end
  redirect '/users'
end
