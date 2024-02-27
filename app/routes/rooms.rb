# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE ROOMS TABLES
# -----------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# GET
# -----------------------------------------------------------------------------------------

# renders the people frame
get '/rooms' do
	@current_user = get_current_user
	get_last_query :rooms
  partial :"frame/rooms"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/rooms/table' do
	get_last_query :rooms
	@objects = Room.search @rooms_query, @rooms_table_settings
	partial :"table/rooms"
end


# copies tghe current query results to the clipboard
# TODO should catch some possible errors from the Cipboard.copy call
get '/rooms/clipboard/copy' do
  get_last_query :rooms
	@objects = Room.search @rooms_query, @rooms_table_settings
	export_string = Room.collection_to_csv @objects,  @rooms_table_settings
	Clipboard.copy export_string
	{result: true}.to_json
end

# renders a single document view
get '/room/:id' do
    @object = (params[:id]=="new" ? nil : Room.find(params[:id]))
    partial :"form/room"
end

# -----------------------------------------------------------------------------------------
# POST
# -----------------------------------------------------------------------------------------
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
	redirect '/rooms'
end

# renders the table of after perfroming a search.
get '/rooms/search' do
	get_last_query :rooms
	@rooms_query = session["rooms_table_query"] = params[:q]
	@objects = Room.search @rooms_query, @rooms_table_settings
	partial :"table/rooms"
end

# renders the table of after perfroming a search.
get '/rooms/house/:house_name' do
	get_table_settings :rooms
	@objects = Room.where(house: params[:house_name]).order(room: :asc)
	partial :"table/rooms"
end

# loads the table settings form
get '/rooms/table/settings' do
	get_table_settings :rooms
	@table_settings = @rooms_table_settings
	partial :"form/table_settings"
end

post '/rooms/table/settings' do
	session["rooms_table_settings"] = TableSettings.create_from_params "rooms", params
	redirect :"/rooms"
end
