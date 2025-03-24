# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE PEOPE TABLE AND ASSOCIATED TABLES
# -----------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------
# GET
# -----------------------------------------------------------------------------------------

DEFAULT_PEOPLE_FILTER = "cb"

# renders the people frame
get '/people' do
	@current_user = get_current_user
	get_last_query_variables :people
	partial :"frame/people"
end

# renders the table of people
# @objects: the people that will be shown in the table
get '/people/table' do
	get_last_query_variables :people
	@people_filter	= session["people_table_filter"]=DEFAULT_PEOPLE_FILTER if @people_filter.nil?
	@objects 				= get_current_people_set
	@decorator 			= PersonDecorator.new(table_settings: @people_table_settings)
	partial :"table/people"
end

# copies tge current query results to the clipboard as a csv text that can be pasted
# in excel
get '/people/clipboard/copy' do
	@objects 				= get_current_people_set
	@decorator 			= PersonDecorator.new(table_settings: @people_table_settings)
	export_results 	= @decorator.entities_to_csv @objects
	{result: true, data: export_results}.to_json
end

# loads the table settings form
get '/people/table/settings' do
	@current_user 	= get_current_user
	@table_settings = get_last_table_settings :people
	@origin 				= "people"
	partial :"form/table_settings"
end

# renders the table of after perfroming a search.
get '/people/search' do
	session["people_table_query"] 	= params[:q]
	session["people_table_filter"] 	= params[:filter]
	@objects 				= get_current_people_set
	@decorator 			= PersonDecorator.new(table_settings: @people_table_settings)
	partial :"table/people"
end

# renders a single person view
get '/person/:id' do
	@current_user = get_current_user
  @person 			= Person.find params[:id]
  partial :"view/person"
end

get '/person/:person_id/permit' do
	redirect "/permit/#{params[:person_id]}?origin=/person/#{params[:person_id]}"
end

# renders a form of a single person view
get '/person/:id/general' do
	@current_user = get_current_user
	@person 			= new_id? ? nil : Person.find(params[:id])
	locals = params[:origin].present? ? {origin: params[:origin], ceremony: params[:ceremony]} : nil
	partial :"form/person/general", locals: locals
end

# renders a form of a single person view
get '/person/:id/:module' do
	@current_user = get_current_user
	@person 			= new_id? ? nil : Person.find(params[:id])
	klass 				= Object.const_get(params[:module].classify)
	@object 			= new_id? ? nil : klass.find_by(person_id: @person.id)
	locals 				= params[:origin].present? ? {origin: params[:origin], ceremony: params[:ceremony]} : nil
	partial :"form/person/#{params[:module]}", locals: locals
end

get '/crs_record/table' do
	@data = CrsRecord.get_ceremony_info(params[:ceremony]) 	if params[:ceremony].present?
	@data = CrsRecord.get_phase_info(params[:phase]) 				if params[:phase].present?
	partial "table/ceremony"
end

# renders a single person view
get '/crs_records' do
	@ceremony = params[:ceremony] if params[:ceremony].present?
	partial :"frame/crs_records"
end

# renders a single person view
get '/guests' do
	@current_user = get_current_user
	partial :"frame/simple_template",  locals: {title: "GUESTS", model_name: "guest", table_name: "guests" }
end

# renders a single person view
get '/guests/table' do
	@table_settings = TableSettings.get(:guests_default)
  @objects = Person.where(ctr: "guest")
	@decorator = PersonDecorator.new(table_settings: @table_settings)
	#ObjectDecorator.new(table_settings: @table_settings)
  partial :"table/simple_template"
end

# renders a single person view
get '/guest/:id' do
	@object = (params[:id]=="new" ? nil : Person.find(params[:id]))
	partial :"form/guest"
end

post '/guest/:id' do
	params[:short_name] = "#{params[:first_name]} #{params[:last_name]}"
	case params[:commit]
		when "new" 		then 	@person = Person.create params
		when "save" 	then (@person = Person.find(params[:id])).update params
		when "delete"
			@person = Person.find(params[:id])
			old_room = Room.find_by(person_id: @person.id)
			old_room.update(person_id: nil) unless old_room.nil?
			@person.destroy
			redirect :"/guests"
	end

	old_room = Room.find_by(person_id: @person.id)
	new_room = params[:room].present? ?  Room.find(params[:room]) : nil

	if old_room!=new_room
		old_room.update(person_id: nil) unless old_room.nil?
		new_room.update(person: @person) unless new_room.nil?
	end

	redirect :"/guests"
end

# Validates if the params received are valid for updating or creating an entity object.
# returns a JSON object of the form {result: boolean, message: string}
post '/guest/:id/validate' do
	content_type :json
	(new_id? ? (Person.validate params) : (Person.find(params[:id]).validate params)).to_json
end

# -----------------------------------------------------------------------------------------
# POST
# -----------------------------------------------------------------------------------------
#
post '/person/:id/general' do
	@current_user = get_current_user
	case params[:commit]
		when "new" 	then 	@person = Person.create params
		when "save" then (@person = Person.find(params[:id])).update params
		when "delete"
			Person.find(params[:id]).destroy
			redirect :"/people"
	end
	partial :"view/person"
end

# Validates if the params received are valid for updating or creating an entity object.
# returns a JSON object of the form {result: boolean, message: string}
post '/person/:id/general/validate' do
	content_type :json
	(new_id? ? (Person.validate params) : (Person.find(params[:id]).validate params)).to_json
end


# this route handles the moduled: personal, study, crs and matrix.
# there is no need to handle the delete action as none of these can be deleted directly
# but only if the person is destroyed
post '/person/:person_id/:module/:id' do
	@current_user = get_current_user
	@person = Person.find(params[:person_id])
	klass = Object.const_get(params[:module].classify)
	object = params[:id]=="new" ? nil : klass.find(params[:id])
	object.nil? ? (klass.create params.except("id")) : (object.update params) if save?
	if (params[:origin].present? && params[:origin]="crs_ceremonies") then redirect "/crs_records?ceremony=#{params[:ceremony]}"
	else partial :"view/person"
	end
end

# uploads an image
post '/people/:id/image' do
 FileUtils.cp_r(params[:file][:tempfile], "app/public/photos/#{params[:id]}.jpg", remove_destination: true)
end

post '/people/table/settings' do
	session["people_table_settings"] = TableSettings.create_from_params "people", params
	redirect :"/people"
end

# -----------------------------------------------------------------------------------------
# ACTIONS
# -----------------------------------------------------------------------------------------

get '/people/:id/document/:doc_id/template_variables' do
	@document = Document.find params[:doc_id]
	@template_variables = @document.get_template_variables
	@set = params[:id]
	partial :'form/report'
end

get '/people/:id/document/:doc_id' do
	document = Document.find params[:doc_id]

	# if the document has template variables we redirect to ask for the variable values
	redirect "/people/#{params[:id]}/document/#{params[:doc_id]}/template_variables" if document.has_template_variables?

	content_type 'application/pdf'

	# if the document needs no input from the user we just render it
	@people = params[:id]=="set" ? get_current_people_set : [Person.find(params[:id])]
	case document.engine
	when "typst"
		send_file (typst document.get_full_path, locals: params)
	when "prawn"
		settings = { page_size: 'A4', page_layout: :portrait, margin: [78, 78, 78, 78] }
		pw = PrawnWriter.new(document)
		prawn (pw.write params), settings if pw.ready?
	end
end



post '/people/:id/document/:doc_id' do
	content_type :pdf

	document = Document.find(params[:doc_id])
	@people = params[:id]=="set" ? get_current_people_set : [Person.find(params[:id])]

	case document.engine
	when "typst"
		send_file (typst document.get_full_path, locals: params)

	when "prawn"
		settings = { page_size: 'A4', page_layout: :portrait, margin: [78, 78, 78, 78] }
		pw = PrawnWriter.new(document)
		prawn (pw.write params), settings if pw.ready?
	end
end

get '/people/cb/json' do
	Person.where(ctr:"cavabianca").to_json
end

# ----------------------------------------------------------------------------------------------------------------------
# BULK EDIT VALUES
# ----------------------------------------------------------------------------------------------------------------------

# shows the form to edit a field of all the people in the set
get '/people/edit_field' do
	@people = get_current_people_set
	partial :"form/set_field"
end

# render the partial containing the input field to bulk edit
get '/people/field/:attribute_name' do
	@attribute = TableSettings.get_attribute(params[:attribute_name])
	partial :"elements/person_field"
end

# commits the changes to the people set
# the method table.classify.constantize get the class given the table name.
post '/people/edit_field' do
	@current_user = get_current_user
	@people = get_current_people_set
	table, field = params[:attribute_id].split(".")

	# simply return if no value was received as a parameter
	return partial :"frame/people" if params[field].strip.blank?

	if table=="people" then @people.update_all(field => params[field])
	else table.classify.constantize.where(person_id: @people.pluck(:id)).update_all(field => params[field])
	end
	partial :"frame/people"
end

# adds one year to each of the people that match the current query
get '/people/set/add_year' do
	@current_user = get_current_user
	@people = get_current_people_set
	partial :"form/add_year"
end

# adds one year to each of the people that match the current query
post '/people/set/add_year' do
	@current_user = get_current_user
	@people = get_current_people_set
	get_current_people_set.each {|person|  person.add_year } if params["commit"]=="save"
	partial :"frame/people"
end