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
	query = @people_filter=="cb" ? "cb AND #{@people_query}" : @people_query
	@objects = Person.search query, @people_table_settings
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
	query = @people_filter=="cb" ? "cb AND #{@people_query}" : @people_query
	@objects = Person.search query, @people_table_settings
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
		when "personal" then @personal = Personal.find_by(person_id: @person.id)
		when "study" 		then @study = Study.find_by(person_id: @person.id)
		when "crs" 			then @crs = Crs.find_by(person_id: @person.id)
		when "matrix"
			@matrix = Matrix.find_by(person_id: @person.id)
			@tasks_available = @matrix.nil? ? [] : @matrix.tasks_available.pluck(:task_id)
		when "rooms", "room"
			@object = Room.find_by(person_id: @person.id)
			@object.nil? ? (redirect "/person/#{params[:id]}") : (return partial :"form/room")
	end
	partial :"form/person/#{params[:module]}"
end

get '/crs/cfi' do
	@objects = Person.where(ctr:0).map{|p| {person:p, people: (Person.includes(:crs).where('crs.cfi' => p.id)).pluck(:id, :short_name) }}
	partial "table/cfi"
end

# updates the cfi of person with id to value cfi
post '/crs/cfi/update/:id/:cfi' do
	(Crs.find_by(person_id:params[:id])).update(cfi: Person.find(params[:cfi]).id)
end

get '/crs/table' do
	@has_date = params[:ceremony].present?
	case params[:ceremony]

		when "fidelidad"
			@title = "Próximas Fidelidades"
			@objects = Person.includes(:crs).where(status: 0).where.not(ctr:3).select{|person| (person.crs!=nil && person&.crs&.get_next_fidelidad!=nil)}
			@objects = @objects.map {|p| [p.id, p.short_name, p.crs&.get_next_fidelidad.strftime("%d-%m-%y")]}
		when "admissio"
			@title = "Próximas Admissio"
			@objects = Person.includes(:crs).where(status: 0).where.not(ctr:3).select{|person| (person.crs!=nil && person&.crs&.get_next_admissio!=nil)}
			@objects = @objects.map {|p| [p.id, p.short_name, p&.crs&.get_next_admissio.strftime("%d-%m-%y")]}
		when "lectorado"
			@title = "Próximos Lectorados"
			@objects = Person.includes(:crs).where(status: 0).where.not(ctr:3).select{|person| (person.crs!=nil && person&.crs&.get_next_lectorado!=nil)}
			@objects = @objects.map {|p| [p.id, p.short_name, p.crs&.get_next_lectorado.strftime("%d-%m-%y")]}
		when "acolitado"
			@title = "Próximos Acolitados"
			@objects = Person.includes(:crs).where(status: 0).where.not(ctr:3).select{|person| (person.crs!=nil && person&.crs&.get_next_acolitado!=nil)}
			@objects = @objects.map {|p| [p.id, p.short_name, p.crs&.get_next_acolitado.strftime("%d-%m-%y")]}
		end

	case params[:phase]
		when "propedeutica"
			@title = "Estapa Propedeútica"
			@objects = Person.joins(:crs).where('crs.phase' => "propedeutica").pluck(:id, :short_name)
		when "discipular"
			@title = "Etapa Discipular"
			@objects = Person.joins(:crs).where('crs.phase' => "discipular").pluck(:id, :short_name)
		when "configuracional"
			@title = "Etapa Configuracional"
			@objects = Person.joins(:crs).where('crs.phase' => "configuracional").pluck(:id, :short_name)
		when "sintesis"
			@title = "Etapa de Síntesis"
			@objects = Person.joins(:crs).where('crs.phase' => "síntesis").pluck(:id, :short_name)
		end
		@total = @objects.size unless @objects.nil?
		partial "table/ceremony"
end

# renders a single person view
get '/crs' do
	@current_user = get_current_user
	@people_o = Person.includes(:crs).where(status: 0).where.not(ctr:3).select{|person| (person&.crs&.get_next_fidelidad!=false)}
	@people_a = Person.includes(:crs).where(status: 0).where.not(ctr:3).select{|person| (person&.crs&.get_next_admissio!=false)}
	@people_l = Person.includes(:crs).where(status: 0).where.not(ctr:3).select{|person| (person&.crs&.get_next_lectorado!=false)}
	@people_propedeutica =  Person.joins(:crs).where('crs.phase' => "propedeutica")
	@people_discipular =  Person.joins(:crs).where('crs.phase' => "discipular")
	@people_configuracional = Person.joins(:crs).where('crs.phase' => "configuracional")
	@people_sintesis = Person.joins(:crs).where('crs.phase' => "síntesis")
	partial :"frame/crs"
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

# this route handles the moduled: personal, study, crs and matrix
post '/person/:id/:module' do
	@person = Person.find(params[:id])
	@current_user = get_current_user
	klass = Object.const_get(params[:module].capitalize)
	object_id_param = params["#{params[:module]}_id".to_sym]
	object = object_id_param=="new" ? nil : klass.find(object_id_param)
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
		crs = @people.map {|person| person.crs}
		crs.each {|crs| crs&.update(params[:att_name].to_sym => params[params[:att_name]])}
	else
		@people.each {|person| person.update(params[:att_name].to_sym => params[params[:att_name]])}
	end
		partial :"frame/people"
end

get '/people/cb/json' do
	Person.where(ctr:"cavabianca").to_json
end
