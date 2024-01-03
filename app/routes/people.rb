########################################################################################
# ROUTES CONTROLLERS FOR THE PEOPLE TABLES
########################################################################################
require"clipboard"

# renders the people frame
get '/people/frame' do
	get_last_query
  partial :"frame/people"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/people/table' do
  get_last_query
	@objects = @query.nil? ? Person.includes(:room).all.order(full_name: :asc) : (Person.search @query)
	partial :"table/people"
end

get '/people/clipboard/copy' do
  get_last_query
	@objects = @query.nil? ? Person.includes(:room).all.order(full_name: :asc) : (Person.search @query)
	export_string = Person.collection_to_csv @objects, @table_settings
	Clipboard.copy export_string
	{result: true}.to_json
end

# toggles a person from the set.
get '/people/table/settings' do
	@table_settings = session["table_settings"].nil? ? TableSettings.new(table: :default) : session["table_settings"]
	partial :"form/table_settings"
end

post '/people/table/settings' do
	session["table_settings"] = TableSettings.create_from_params params
	partial :"frame/people"
end

# renders the table of after perfroming a search.
get '/people/search' do
	@objects = Person.search(params[:q],params[:sort_order])
	@table_settings = session["table_settings"].nil? ? TableSettings.new(table: :default) : session["table_settings"]
	session["table_query"] = params[:q]
	puts Rainbow("setting session[table_query] to: #{session["table_query"]}").yellow
	partial :"table/people"
end

# renders a single person view
get '/person/:id' do
  @person = Person.find(params[:id])
  partial :"view/person"
end

# renders a form of a single person view
get '/person/:id/:module' do
	@person = (params[:id]=="new" ? nil : Person.find(params[:id]))
	case params[:module]
		when "personal" then @personal = Personal.find_by(person_id: @person.id)
		when "study" 		then @study = Study.find_by(person_id: @person.id)
		when "crs" 			then @crs = Crs.find_by(person_id: @person.id)
	end
	partial :"form/person/#{params[:module]}"
end

########################################################################################
# POST ROUTES
########################################################################################
post '/person/:id/general' do
	@person = (params[:id]=="new" ? nil : Person.find(params[:id]))
	case params[:commit]
		when "save"     
			if @person.nil? 
				@person = Person.create_from_params params
			else
				check_update_result (@person.update_from_params params)
			end
		# if a person was deleted we go back to the screen fo the people table
		when "delete" 
				@person.destroy
				redirect '/people/table'
	end
	partial :"view/person"
end

# post controller of the personal data of a person
post '/person/:id/personal' do
    @person = Person.find(params[:id])
    @personal = params[:personal_id]=="new" ? nil : Personal.find(params[:personal_id])
    if params[:commit]=="save"
			if @personal.nil?
				@personal = Personal.create Personal.prepare_params params
			else
				check_update_result (@personal.update Personal.prepare_params params)
			end    
    end    
    partial :"view/person"
end

# post controller of the study data of a person
post '/person/:id/study' do
	@person = Person.find(params[:id])
	@study = params[:studies_id]=="new" ? nil : Study.find(params[:studies_id])
	if params[:commit]=="save"
		if @study.nil?
			@study = Study.create Study.prepare_params params
		else
			check_update_result (@study.update Study.prepare_params params)
		end    
	end    
	partial :"view/person"
end

# post controller of the crs data of a person
post '/person/:id/crs' do
	@person = Person.find(params[:id])
	@crs = params[:crs_id]=="new" ? nil : Crs.find(params[:crs_id])
	if params[:commit]=="save"
		if @crs.nil?
			@crs = Crs.create Crs.prepare_params params
		else
			check_update_result (@crs.update Crs.prepare_params params)
		end    
	end    
	partial :"view/person"
end


# uploads an image
post '/people/:id/image' do
    FileUtils.cp(params[:file][:tempfile], "app/public/photos/#{params[:id]}.jpg")
end


########################################################################################
# ACTIONS ON PEOPLE SETS
########################################################################################


# renders a pdf or an excel file with the params received.
get '/people/:id/document/:doc_id' do
	if params[:id]=="set"
		get_last_query
		@people = @query.nil? ? Person.all.order(full_name: :asc) : (Person.search @query)
	else
		@people = [Person.find(params[:id])]
	end
	@document = Document.find(params[:doc_id])
	puts "found document #{@document.to_s}"
	@writer = @document.get_writer @people
	case @writer.status
		when DocumentWriter::WARNING
			puts Rainbow(@writer.message).orange
		when DocumentWriter::FATAL
			puts Rainbow(@writer.message).red
			return partial :"errors/writer_error"
	end
	puts "found writer #{@writer.to_s}"
	case @document.engine
	when "prawn"
		headers 'content-type' => "application/pdf"	
		body @writer.render
	when "excel" 
		send_file @writer.render(), :filename => "#{@document.name}.xlsx"
	when "typst"
		if @document.has_template_variables?
				@person = @people[0]
				@template_variables = @document.get_template_variables
				return partial :'form/report' 
		end
		case @writer.status
			when DocumentWriter::WARNING
				puts Rainbow(@writer.message).orange
			when DocumentWriter::FATAL
				puts Rainbow(@writer.message).red
				return partial :"errors/writer_error"
		end
	OS.windows? ?	(send_file @writer.render) : (body @writer.render)
	end
end

post '/people/:id/document/:doc_id' do
	headers 'content-type' => "application/pdf"
	if params[:id]=="set"
		get_last_query
		@people = @query.nil? ? Person.all.order(full_name: :asc) : (Person.search @query)
	else
		@people = [Person.find(params[:id])]
	end
		@document = Document.find(params[:doc_id])
	@writer = @document.get_writer(@people, params)
	case @writer.status
		when DocumentWriter::WARNING
			puts Rainbow(@writer.message).orange
		when DocumentWriter::FATAL
			puts Rainbow(@writer.message).red
			return partial :"errors/writer_error"
	end 
	OS.windows? ? (send_file @writer.render) : (body @writer.render)
end

# shows the form to edit a field of all the people in the set
get '/people/edit_field' do
	partial :"form/set_field"
end

post '/people/edit_field' do
	puts Rainbow("got params #{params}").yellow
	get_last_query
	@people = @query.nil? ? Person.all.order(full_name: :asc) : (Person.search @query)
	@people.each {|person| person.update(params[:att_name].to_sym => params[params[:att_name]])}
	partial :"frame/people"
end