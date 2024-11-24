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
	@objects 				= Person.search @people_query, @people_table_settings, @people_filter
	@decorator 			= PersonDecorator.new(table_settings: @people_table_settings)
	partial :"table/people"
end

# copies tge current query results to the clipboard as a csv text that can be pasted
# in excel
get '/people/clipboard/copy' do
  get_last_query_variables :people
	@objects 				= Person.search @people_query, @people_table_settings, @people_filter
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
	get_last_query_variables :people
	@people_query 	= session["people_table_query"] = params[:q]
	@people_filter	= session["people_table_filter"] = params[:filter]
	@objects 				= Person.search @people_query, @people_table_settings, @people_filter
	@decorator 			= PersonDecorator.new(table_settings: @people_table_settings)
	partial :"table/people"
end

# renders a single person view
get '/person/:id' do
	@current_user = get_current_user
  @person = Person.find(params[:id])
  partial :"view/person"
end

get '/person/:person_id/permit' do
	redirect "/permit/#{params[:person_id]}?origin=/person/#{params[:person_id]}"
end

# renders a form of a single person view
get '/person/:id/:module' do
	@current_user = get_current_user()
	@person = new_id? ? nil : Person.find(params[:id])
	case params[:module]
		when "personal" 	then @personal 		= 	Personal.find_by(person_id: @person.id)
		when "study" 			then @study 			= 	Study.find_by(person_id: @person.id)
		when "crs_record" then @crs 				= 	CrsRecord.find_by(person_id: @person.id)
		when "permit"
			@permit = Permit.find_by(person_id: @person.id)
			@permit = Permit.create(person: @person) unless @permit
		when "matrix"
			@matrix = Matrix.find_by(person_id: @person.id)
			@tasks_available = @matrix.nil? ? [] : @matrix.tasks_available.pluck(:task_id)
		when "rooms", "room"
			@object = Room.find_by(person_id: @person.id)
			@object.nil? ? (redirect "/person/#{params[:id]}") : (return partial :"form/room")
	end
	locals = params[:origin].present? ? {origin: params[:origin], ceremony: params[:ceremony]} : nil
	partial :"form/person/#{params[:module]}", locals: locals
end

get '/crs_record/table' do
	@has_date = params[:ceremony].present?

	if params[:ceremony].present?
		@objects = Person.includes(:crs_record).laicos.in_rome.select{|person| (person.crs_record&.get_next(params[:ceremony].to_sym)!=nil)}
		@objects = @objects.map {|p| [p.id, p.short_name, p.crs_record.get_next(params[:ceremony].to_sym).strftime("%d-%m-%y")]}
		@ceremony = params[:ceremony]
		@title = case params[:ceremony]
			when "fidelidad" 	then 	"Próximas Fidelidades"
			when "admissio" 	then	"Próximas Admissio"
			when "lectorado"	then	"Próximos Lectorados"
			when "acolitado"	then 	"Próximos Acolitados"
		end
	end

	if params[:phase].present?
		@objects 	= Person.phase(params[:phase]).pluck(:id, :short_name)
		@title 		= "Etapa #{CrsRecord.phases.key(params[:phase].to_i)}".capitalize
	end

	@total = @objects.size unless @objects.nil?
	partial "table/ceremony"
end

# renders a single person view
get '/crs_records' do
	@ceremony = params[:ceremony] if params[:ceremony].present?
	partial :"frame/crs_records"
end

# -----------------------------------------------------------------------------------------
# POST
# -----------------------------------------------------------------------------------------
#
post '/person/:id/general' do
	@current_user = get_current_user
	case params[:commit]
		when "new" 	then @person = Person.create params
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
	@person = Person.find(params[:person_id])
	@current_user = get_current_user
	klass = Object.const_get(params[:module].classify)
	object = params[:id]=="new" ? nil : klass.find(params[:id])
	object.nil? ? (klass.create params) : (object.update params) if save?
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

# renders a pdf with the params received.
get '/people/:id/document/:doc_id' do

	@document = Document.find params[:doc_id]
	# ff the document has template variables we redirect to ask for the variable values
	redirect "/people/#{params[:id]}/document/#{params[:doc_id]}/template_variables" if @document.has_template_variables?

	# find the people records
	get_last_query_variables params["query"].to_sym
	people =
		if params[:id]=="set" then Person.search @people_query, @people_table_settings, @people_filter
		else [Person.find(params[:id])]
		end
	@document.get_writer(people).render_document
end

post '/people/:id/document/:doc_id' do
	# find the people records
	get_last_query_variables params["query"].to_sym

	people =
		if params[:id]=="set" then Person.search @people_query, @people_table_settings, @people_filter
		else [Person.find(params[:id])]
		end
	document = Document.find(params[:doc_id])
	document.get_writer(people, params).render_document
end

get '/people/cb/json' do
	Person.where(ctr:"cavabianca").to_json
end

# ----------------------------------------------------------------------------------------------------------------------
# BULK EDIT VALUES
# ----------------------------------------------------------------------------------------------------------------------

# shows the form to edit a field of all the people in the set
get '/people/edit_field' do
	get_last_query_variables :people
	@people = @people_query.nil? ? Person.all : (Person.search @people_query, @people_table_settings)
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
	get_last_query_variables :people
	@people = @people_query.nil? ? Person.all : (Person.search @people_query, @people_table_settings)
	table, field = params[:attribute_id].split(".")

	# simply return if no value was received as a parameter
	return partial :"frame/people" if params[field].strip.blank?

	if table=="people" then @people.update_all(field => params[field])
	else table.classify.constantize.where(person_id: @people.pluck(:id)).update_all(field => params[field])
	end
	partial :"frame/people"
end

get '/people/set/add_year' do
	get_last_query_variables :people
	@people = @people_query.nil? ? Person.all : (Person.search @people_query, @people_table_settings)
	@people.each do |person|
		if person.year!=nil
			begin
				person.year = (person.year.to_i+1).to_s unless person.year.nil?
				person.save
			rescue
				puts Rainbow("PULPO: could not add year of #{person.short_name}. #{person.year} is not an integer.}").orange
			end
		end
	end
end