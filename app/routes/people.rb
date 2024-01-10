########################################################################################
# ROUTES CONTROLLERS FOR THE PEOPLE TABLES
########################################################################################
require"clipboard"

# renders the people frame
get '/people/frame' do
	get_last_query :people
  partial :"frame/people"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/people/table' do
  get_last_query :people
	@objects = Person.search @people_query, @people_table_settings
	partial :"table/people"
end

# copies tghe current query results to the clipboard
# TODO should catch some possible errors from the Cipboard.copy call
get '/people/clipboard/copy' do
  get_last_query :people
	@objects = Person.search @people_query, @people_table_settings
	export_string = Person.collection_to_csv @objects,  @people_table_settings
	Clipboard.copy export_string
	{result: true}.to_json
end

# loads the table settings form
get '/people/table/settings' do
	get_table_settings :people
	puts "IN GET /people/table/settings. Got @table_settings with attributes #{@people_table_settings.att}"
	@table_settings = @people_table_settings
	puts Rainbow("Table Settings: #{@table_settings}").purple
	partial :"form/table_settings"
end

post '/people/table/settings' do
	session["people_table_settings"] = TableSettings.create_from_params "people", params
	puts "got @query in post #{@people_query}"
	redirect :"/people/frame"
end

# renders the table of after perfroming a search.
get '/people/search' do
	get_table_settings :people
	@people_query = session["people_table_query"] = params[:q]
	@objects = Person.search @people_query, @people_table_settings
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
		when "rooms" 		
			@object = Room.find_by(person_id: @person.id)
			@object.nil? ? (redirect "/person/#{params[:id]}") : (return partial :"form/room")
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
		get_last_query :people
		puts "got @people_query #{@people_query}"
		@people = @people_query.nil? ? Person.all.order(family_name: :asc) : (Person.search @people_query, @people_table_settings).order(family_name: :asc)
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
				puts Rainbow("Document has template variables").red
				@template_variables = @document.get_template_variables
				@set = params[:id]
				return partial :'form/report' 
		else
			puts Rainbow("Document has NO template variables").red
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
		get_last_query :people
		puts "got @people_query #{@people_query}"
		@people = @people_query.nil? ? Person.all.order(family_name: :asc) : (Person.search @people_query, @people_table_settings).order(family_name: :asc)
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
	get_last_query :people
	@people = @people_query.nil? ? Person.all.order(family_name: :asc) : (Person.search @people_query, @people_table_settings).order(family_name: :asc)
	@people.each {|person| person.update(params[:att_name].to_sym => params[params[:att_name]])}
	partial :"frame/people"
end