########################################################################################
# ROUTES CONTROLLERS FOR THE PEOPLE TABLES
########################################################################################

# renders the people frame
get '/rooms/frame' do
    print_controller_log
    partial :"frame/rooms"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/rooms/table' do
    print_controller_log
    @objects = Room.all
    partial :"table/rooms"
end

# renders a single document view
get '/room/:id' do
    @object = (params[:id]=="new" ? nil : Room.find(params[:id]))
    puts "OBJECT #{@object.nil?}"
    partial :"form/room"
end


########################################################################################
# POST ROUTES
########################################################################################
post '/room/:id' do
    print_controller_log
    @room = (params[:id]=="new" ? nil : Room.find(params[:id]))
    case params[:commit]
        when "save"     
            if @room.nil? 
                @room = Room.create_from_params params
            else
                res = @room.update_from_params params
                check_update_result res
            end
        # if a person was deleted we go back to the screen fo the people table
        when "delete" then @room.destroy
    end
    redirect '/rooms/frame'
end



    # renders the table of after perfroming a search.
    get '/rooms/search' do
        print_controller_log
        @objects = Room.search(params[:q],params[:sort_order])
        partial :"table/rooms"
    end
    