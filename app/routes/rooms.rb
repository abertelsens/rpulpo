# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE ROOMS TABLES
# -----------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# GET
# -----------------------------------------------------------------------------------------

# renders the people frame
get '/rooms' do
	@current_user = get_current_user
	get_last_query_variables :rooms
  partial :"frame/rooms"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/rooms/table' do
	get_last_query_variables :rooms
	@objects 		= Room.search @rooms_query, @rooms_table_settings
	@decorator 	= RoomDecorator.new(table_settings: @rooms_table_settings)
	partial :"table/rooms"
end

# copies tghe current query results to the clipboard
# TODO should catch some possible errors from the Cipboard.copy call
get '/rooms/clipboard/copy' do
  get_last_query_variables :rooms
	@objects 			= Room.search @rooms_query, @rooms_table_settings
	@decorator 		= RoomDecorator.new(table_settings: @rooms_table_settings)
	export_string = @decorator.entities_to_csv @objects
	{result: true, data: export_string}.to_json
end

# renders a single document view
get '/room/:id' do
    @object = (params[:id]=="new" ? nil : Room.find(params[:id]))
    partial :"form/room"
end

# renders the table of after perfroming a search.
get '/rooms/search' do
	get_last_query_variables :rooms
	@rooms_query 	= session["rooms_table_query"] = params[:q]
	@objects 			= Room.search @rooms_query, @rooms_table_settings
	@decorator 		= RoomDecorator.new(table_settings: @rooms_table_settings)
	partial :"table/rooms"
end

get '/rooms/house/:house_name' do
	get_last_query_variables :rooms
	@rooms_query 	= session["rooms_table_query"] = "#{params[:house_name]}"
	@objects 			= Room.includes(:person).where(house: params[:house_name]).order(room: :asc)
	@decorator 		= RoomDecorator.new(table_settings: @rooms_table_settings)
	partial :"table/rooms"
end

# loads the table settings form
get '/rooms/table/settings' do
	@current_user 	= get_current_user
	@table_settings = get_last_table_settings :rooms
	@origin 				= "rooms"
	partial :"form/table_settings"
end

# -----------------------------------------------------------------------------------------
# POST
# -----------------------------------------------------------------------------------------

post '/room/:id' do
	room = Room.find params[:id] unless new_id?
	case params[:commit]
	when "new"
		room = Room.create_from_params params
	when "save"
			res = room.update_from_params params
			check_update_result res
	when "delete" then room.destroy
	end
	redirect '/rooms'
end

post '/rooms/table/settings' do
	session["rooms_table_settings"] = TableSettings.create_from_params "rooms", params
	redirect :"/rooms"
end
