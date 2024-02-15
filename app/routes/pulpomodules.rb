########################################################################################
# ROUTES CONTROLLERS FOR THE PEOPLE TABLES
########################################################################################


# renders the people frame after setting the current peopleset
get '/modules' do
    @current_user = get_current_user
    partial :"frame/modules"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/modules/table' do
    
    @objects = PulpoModule.all.order(name: :asc)
    partial :"table/modules"
end

# renders a single document view
get '/module/:id' do
    @object = (params[:id]=="new" ? nil : PulpoModule.find(params[:id]))
    puts "OBJECT #{@object.nil?}"
    partial :"form/module"
end


########################################################################################
# POST ROUTES
########################################################################################
post '/module/:id' do
    
    @module = (params[:id]=="new" ? nil : PulpoModule.find(params[:id]))
    case params[:commit]
        when "save"     
            if @module.nil? 
                @module = PulpoModule.create_from_params params
            else
                res = @module.update_from_params params
                check_update_result res
            end
        # if a person was deleted we go back to the screen fo the people table
        when "delete" 
            @module.destroy
            redirect '/modules'
    end
    redirect '/modules'
end