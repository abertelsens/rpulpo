########################################################################################
# ROUTES CONTROLLERS FOR THE USERS TABLES
########################################################################################

########################################################################################
# GET ROUTES
########################################################################################

get '/user/validate' do
    content_type :json
    (User.validate params).to_json
end

# renders the people frame after setting the current peopleset
get '/users' do
    @current_user = get_current_user
    partial :"frame/users"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/users/table' do
    @objects = User.all.order(uname: :asc)
    partial :"table/user"
end

# renders a single document view
get '/user/:id' do
    @object = (params[:id]=="new" ? nil : User.find(params[:id]))
    partial :"form/user"
end

########################################################################################
# POST ROUTES
########################################################################################

post '/user/:id' do
    @user = (params[:id]=="new" ? nil : User.find(params[:id]))
    case params[:commit]
        when "save"
            @user  = @user.nil? ? (User.create params) : (@user.update params)
            check_update_result @user
        when "delete" 
            @user.destroy
    end
    redirect '/users'
end

