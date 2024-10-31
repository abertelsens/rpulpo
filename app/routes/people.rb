# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE PEOPE TABLES
# -----------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# GET
# -----------------------------------------------------------------------------------------

# renders the people frame
get '/people' do
	@current_user = get_current_user
	get_last_query :people
	get_last_filter :people
  partial :"frame/people"
end

# renders the table of people
# @objects: the people that will be shown in the table
get '/people/table' do
  get_last_query :people
	get_last_filter :people
	# if the people filter is not set yet then we set it to cb as default
	@people_filter = session["people_table_filter"]="cb" if @people_filter.nil?
	@objects = Person.search @people_query, @people_table_settings, @people_filter
	partial :"table/people"
end

# copies tge current query results to the clipboard
# TODO should catch some possible errors from the Cipboard.copy call
get '/people/clipboard/copy' do
  get_last_query :people
	@objects = Person.search @people_query, @people_table_settings
	export_string = Person.collection_to_csv @objects,  @people_table_settings
	{result: true, data: export_string}.to_json
end

# loads the table settings form
get '/people/table/settings' do
	@current_user = get_current_user
	get_table_settings :people
	@table_settings = @people_table_settings
	partial :"form/table_settings"
end

# renders the table of after perfroming a search.
get '/people/search' do
	get_table_settings :people
	@people_query = session["people_table_query"] = params[:q]
	@people_filter = session["people_table_filter"] = params[:filter]
	@objects = Person.search @people_query, @people_table_settings, @people_filter
	partial :"table/people"
end

# renders a single person view
get '/person/:id' do
	@current_user = get_current_user
  @person = Person.find(params[:id])
  partial :"view/person"
end

# renders a form of a single person view
get '/person/:id/:module' do
	@current_user = get_current_user()
	@person = (params[:id]=="new" ? nil : Person.find(params[:id]))
	case params[:module]
		when "personal" 	then @personal 	= Personal.find_by(person_id: @person.id)
		when "study" 			then @study 		= Study.find_by(person_id: @person.id)
		when "crs_recor" 	then @crs 			= CrsRecord.find_by(person_id: @person.id)
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
	partial :"form/person/#{params[:module]}"
end

get '/crs_record/table' do
	@has_date = params[:ceremony].present?
	
	if params[:ceremony].present?
		@objects = Person.includes(:crs_record).laicos.in_rome.select{|person| (person.cr_records&.get_next(params[:ceremony].to_sym)!=nil)}
		@objects = @objects.map {|p| [p.id, p.short_name, p.crs_record.get_next(params[:ceremony].to_sym).strftime("%d-%m-%y")]}
		@title = case params[:ceremony]
			when "fidelidad" 	then 	"Próximas Fidelidades"
			when "admissio" 	then	"Próximas Admissio"
			when "lectorado"	then	"Próximos Lectorados"
			when "acolitado"	then 	"Próximos Acolitados"
		end
	end
	
	if params[:phase].present?
		@objects = Person.phase(params[:phase]).pluck(:id, :short_name)
		@title = "Etapa #{Crs.phases.key(params[:phase].to_i)}".capitalize
	end

	@total = @objects.size unless @objects.nil?
	partial "table/ceremony"
end

# renders a single person view
get '/crs_records' do
	partial :"frame/crs_records"
end

# shows the form to edit a field of all the people in the set
get '/people/edit_field' do
	partial :"form/set_field"
end

# -----------------------------------------------------------------------------------------
# POST
# -----------------------------------------------------------------------------------------
#
post '/person/:id/general' do
	@current_user = get_current_user
	@person = (params[:id]=="new" ? nil : Person.find(params[:id]))
	case params[:commit]
		when "save" then @person.nil? ? (@person =  Person.create params) : (@person.update params) if save?
		# if a person was deleted we go back to the screen fo the people table
		when "delete"
			@person.destroy
			redirect :"/people"
	end
	partial :"view/person"
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
	partial :"view/person"
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

# renders a pdf or an excel file with the params received.
get '/people/:id/document/:doc_id' do
	if params[:id]=="set"
		get_last_query :people
		@people = @people_query.nil? ? Person.all.order(family_name: :asc) : (Person.search @people_query, @people_table_settings).order(family_name: :asc)
	else
		@people = [Person.find(params[:id])]
	end

	@document = Document.find(params[:doc_id])
	@writer = @document.get_writer @people
	case @writer.status
		when DocumentWriter::WARNING then puts Rainbow(@writer.message).orange
		when DocumentWriter::FATAL
			puts Rainbow(@writer.message).red
			return partial :"errors/writer_error"
	end

	if @document.has_template_variables?
			@template_variables = @document.get_template_variables
			@set = params[:id]
			return partial :'form/report'
	end

	case @writer.status
		when DocumentWriter::WARNING then puts Rainbow(@writer.message).orange
		when DocumentWriter::FATAL
			puts Rainbow(@writer.message).red
			return partial :"errors/writer_error"
	end
	send_file @writer.render
end

post '/people/:id/document/:doc_id' do
	headers 'content-type' => "application/pdf"
	if params[:id]=="set"
		get_last_query :people
		@people = @people_query.nil? ? Person.all : (Person.search @people_query, @people_table_settings)
	else
		@people = [Person.find(params[:id])]
	end

	@document = Document.find(params[:doc_id])
	@writer = @document.get_writer(@people, params)

	case @writer.status
		when DocumentWriter::WARNING then puts Rainbow(@writer.message).orange
		when DocumentWriter::FATAL
			puts Rainbow(@writer.message).red
			return partial :"errors/writer_error"
	end
	send_file @writer.render, :type => :pdf
end

post '/people/edit_field' do
	puts Rainbow("got params #{params}").yellow
	@current_user = get_current_user()
	get_last_query :people
	@people = @people_query.nil? ? Person.all.order(family_name: :asc) : (Person.search @people_query, @people_table_settings).order(family_name: :asc)
	if params[:att_name]=="phase"
		crs = @people.map {|person| person.crs_record}
		crs.each {|crs| crs&.update(params[:att_name].to_sym => params[params[:att_name]])}
	else
		@people.each {|person| person.update(params[:att_name].to_sym => params[params[:att_name]])}
	end
		partial :"frame/people"
end

get '/people/cb/json' do
	Person.where(ctr:"cavabianca").to_json
end
