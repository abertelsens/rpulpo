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
  @table_settings = TableSettings.get(:users_default)
  @objects = User.all
  @decorator = ObjectDecorator.new(table_settings: @table_settings)
  partial :"table/simple_template"
end

# renders a user form
get '/user/:id' do
    @object = (params[:id]=="new" ? nil : User.find(params[:id]))
    # get a has with the permissions of the user
    @permissions = @object.pulpo_module_ids if @object
    #@permissions = @object.get_permissions if @object
    partial :"form/user"
end

# -----------------------------------------------------------------------------------------
# POST ROUTES
# -----------------------------------------------------------------------------------------

post '/user/:id' do
	case params[:commit]
		when "new"		then	User.create params
		when "save" 	then 	User.find(params[:id]).update params
		when "delete" then 	User.find(params[:id]).destroy
	end
	redirect '/users'
end

# Validates if the params received are valid for updating or creating an entity object.
# returns a JSON object of the form {result: boolean, message: string}
post '/user/:id/validate' do
	content_type :json
	(new_id? ? (User.validate params) : (User.find(params[:id]).validate params)).to_json
end
