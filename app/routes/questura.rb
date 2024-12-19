# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE ROOMS TABLES
# -----------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# GET
# -----------------------------------------------------------------------------------------

# renders the people frame
get '/permits' do
	@current_user = get_current_user
	get_last_query_variables :permits
  partial :"frame/permits"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/permits/table' do
	get_last_query_variables :permits
	# get only the people thta are students.
	@objects = (Person.search "students AND #{@permits_query}", @permits_table_settings).order("permits.permit_expiration desc")
	@decorator = PermitDecorator.new(table_settings: @permits_table_settings)
	partial :"table/permits"
end


# copies tghe current query results to the clipboard
# TODO should catch some possible errors from the Cipboard.copy call
get '/permits/clipboard/copy' do
  get_last_query_variables :permits
	@objects = Permit.search @permits_query, @permits_table_settings
	@decorator = PermitDecorator.new(table_settings: @permits_table_settings)
	export_string = @decorator.entities_to_csv @objects
	#puts "EXPORT STRING\n\n\n\n"
	#puts export_string
	{result: true, data: export_string}.to_json
end

# renders a single document view
get '/permit/:person_id' do
	@current_user = get_current_user
	@person = Person.find(params[:person_id])
	@permit = Permit.find_by(person: @person)
	partial :"form/permit", locals: {origin: params[:origin]}
end

# -----------------------------------------------------------------------------------------
# POST
# -----------------------------------------------------------------------------------------
post '/permit/:id' do
	@permit = (params[:id]=="new" ? nil : Permit.find(params[:id]))
	case params[:commit]
		when "save"
			if @permit.nil? then @permit = Permit.create params
			else
				res = @permit.update params
				check_update_result res
			end
		# if a person was deleted we go back to the screen fo the people table
		when "delete" then @permit.destroy
	end
	params[:origin].nil? ? (redirect '/permits') :(redirect params[:origin])
end

# renders the table of after perfroming a search.
get '/permits/search' do
	get_last_query_variables :permits
	@permits_query = session["permits_table_query"] = params[:q]
	@permits_filter = session["permits_table_filter"] = params[:filter]
	@objects = (Person.search "students AND #{@permits_query}" , @permits_table_settings).order("permits.permit_expiration desc")
	@decorator = PermitDecorator.new(table_settings: @permits_table_settings)
	partial :"table/permits"
end

# loads the table settings form
get '/permits/table/settings' do
	@current_user = get_current_user
	@table_settings = get_last_table_settings :permits
	@origin = "permits"
	partial :"form/table_settings", locals: {table: "permits"}
end

post '/permits/table/settings' do
	session["permits_table_settings"] = TableSettings.create_from_params "permits", params
	redirect :"/permits"
end
