########################################################################################
# ROUTES CONTROLLERS FOR THE USERS TABLES
########################################################################################

########################################################################################
# GET ROUTES
########################################################################################


# renders the people frame after setting the current peopleset
get '/entities' do
    @current_user = get_current_user
    partial :"frame/entities"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/entities/table' do
    puts Rainbow("HERE").red
    @objects = Entity.all.order(name: :asc)
    partial :"table/entity"
end

# renders a single document view
get '/entity/:id' do
    @object = (params[:id]=="new" ? nil : Entity.find(params[:id]))
    partial :"form/entity"
end

########################################################################################
# POST ROUTES
########################################################################################

post '/entity/:id' do
    @entity = (params[:id]=="new" ? nil : Entity.find(params[:id]))
    case params[:commit]
        when "save"
            @entity  = @entity.nil? ? (Entity.create_from_params params) : (@entity.update_from_params params)
            check_update_result @entity
        when "delete" 
            @entity.destroy
    end
    redirect '/entities'
end

