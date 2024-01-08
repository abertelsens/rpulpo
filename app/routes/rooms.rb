########################################################################################
# ROUTES CONTROLLERS FOR THE PEOPLE TABLES
########################################################################################

# renders the people frame
get '/rooms/frame' do
	get_last_query :rooms
  partial :"frame/rooms"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/rooms/table' do
	get_last_query :rooms
	@objects = Room.includes(:person).all.order(house: :asc, name: :asc)
	partial :"table/rooms"
end

# renders a single document view
get '/room/:id' do
    @object = (params[:id]=="new" ? nil : Room.find(params[:id]))
    partial :"form/room"
end


########################################################################################
# POST ROUTES
########################################################################################
post '/room/:id' do
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
	get_last_query :rooms
	@objects = Room.search(params[:q],params[:sort_order])
	partial :"table/rooms"
end

# renders the table of after perfroming a search.
get '/rooms/house/:house_name' do
	@objects = Room.where(house: params[:house_name]).order(name: :asc)
			partial :"table/rooms"
	end

	# loads the table settings form
get '/rooms/table/settings' do
	get_table_settings :rooms
	puts "IN GET /room/table/settings. Got @table_settings with attributes #{@rooms_table_settings.att}"
	@table_settings = @rooms_table_settings
	puts "@table_settings main table #{@table_settings.main_table}"
	partial :"form/table_settings"
end

post '/rooms/table/settings' do
	session["room_table_settings"] = TableSettings.create_from_params params
	puts "got @query in post #{@rooms_query}"
	redirect :"/rooms/frame"
end