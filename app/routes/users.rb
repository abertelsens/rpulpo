########################################################################################
# ROUTES CONTROLLERS FOR THE PEOPLE TABLES
########################################################################################

get '/user/validate' do
    content_type :json
    (User.validate params).to_json
end


# renders the people frame after setting the current peopleset
get '/users/frame' do
    print_controller_log
    partial :"frame/users"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/users/table' do
    print_controller_log
    @objects = User.all.order(uname: :asc)
    partial :"table/user"
end


# renders a single document view
get '/user/:id' do
    @object = (params[:id]=="new" ? nil : User.find(params[:id]))
    puts "OBJECT #{@object.nil?}"
    partial :"form/user"
end


########################################################################################
# POST ROUTES
########################################################################################
post '/user/:id' do
    print_controller_log
    @user = (params[:id]=="new" ? nil : User.find(params[:id]))
    case params[:commit]
        when "save"
            if @user.nil? 
                @user = User.create_from_params params
            else
                res = @user.update_from_params params
                check_update_result res
            end
        # if a person was deleted we go back to the screen fo the people table
        when "delete" then @user.destroy
    end
    redirect '/users/frame'
end

