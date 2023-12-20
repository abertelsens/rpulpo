########################################################################################
# ROUTES CONTROLLERS FOR THE PEOPLE SETS TABLE
########################################################################################

########################################################################################
# PEOPLE SETS
########################################################################################

# renders the lists frame after setting the current peopleset
get '/lists/frame' do
	@peopleset = get_current_peopleset
	partial :"frame/lists"
end

# renders the table of people after updating the current set.
# @objects the people that will be shown in the table
# @peopleset_ids: an array of ids that is used to highlight the people that belong to the set
get '/people/peopleset/:id/table' do
	@peopleset = Peopleset.find(params[:id])
	set_current_peopleset @peopleset
	@peopleset_ids = @peopleset.get_people.map {|p| p.id }
	@objects = Person.all.order(full_name: :asc)
	partial :"table/people_list"
end

# renders the table of after perfroming a search.
get '/people/peopleset/search' do
	@peopleset = get_current_peopleset
	@peopleset_ids = @peopleset.get_people.map {|p| p.id }
	@objects = Person.search(params[:q],params[:sort_order])
	partial :"table/people_list"
end

# renders the viewer of the set
get '/people/peopleset/:id/view' do
	set_current_peopleset = params[:id].to_i
	@peopleset = Peopleset.find(params[:id])
	@people = @peopleset.get_people
	partial :"view/peopleset"
end

# renders the viewer of the set
get '/people/peopleset/:id/header' do
	@peopleset = Peopleset.find(params[:id])
	partial :"components/lists_header"
end

# saves the people set, updates the currnet set to the new saved one and reloads all the frame to correctly reflect the changes
post '/people/peopleset/:id/save' do
	@peopleset = Peopleset.find(params[:id])
	if params[:commit]=="save" && @peopleset.temporary?
		@peopleset.update(name: params[:name], status:Peopleset::SAVED)     #saves the current set 
		Peopleset.create(status:Peopleset::TEMPORARY)                       #creates a new temporary set to ensure we have one
		session[:current_people_set]=@peopleset.id
	elsif params[:commit]=="save"
		@peopleset.update(name: params[:name], status:Peopleset::SAVED)
	elsif params[:commit]=="delete"
		@peopleset.destroy
		session[:current_people_set]=nil
	end
	partial :"components/lists_header"
end

# shows the edit form to create or edit a set
get '/people/peopleset/:id/edit' do
	@peopleset = Peopleset.find(params[:id])
	partial :"form/peopleset"
end

########################################################################################
# ACTIONS ON PEOPLE SETS
########################################################################################

# shows the form to edit a field of all the people in the set
get '/people/peopleset/:id/edit_field' do
	@peopleset = Peopleset.find(params[:id])
	partial :"form/set_field"
end

post '/people/peopleset/:id/edit_field' do
	puts Rainbow("got params #{params}").yellow
	@peopleset = Peopleset.find(params[:id])
	@people = @peopleset.get_people
	@peopleset.edit(params[:att_name], params[params[:att_name]])
	partial :"view/peopleset"
end

# renders a pdf or an excel file with the params received.
get '/people/peopleset/:set_id/document/:doc_id' do
	@peopleset = Peopleset.find(params[:set_id])
	@document = Document.find(params[:doc_id])
	@writer = @document.get_writer @peopleset.get_people
	case @document.engine
	when "prawn"
		headers 'content-type' => "application/pdf"	
		body @writer.render
	when "excel" 
		send_file @writer.render(), :filename => "#{@document.name}.xlsx"
	when "typst"
		if @document.has_template_variables?
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

post '/people/peopleset/:set_id/document/:doc_id' do
	headers 'content-type' => "application/pdf"
	@peopleset = Peopleset.find(params[:set_id])
	@document = Document.find(params[:doc_id])
	@writer = @document.get_writer(@peopleset.get_people, params)
	case @writer.status
		when DocumentWriter::WARNING
			puts Rainbow(@writer.message).orange
		when DocumentWriter::FATAL
			puts Rainbow(@writer.message).red
			return partial :"errors/writer_error"
	end 
	OS.windows? ? (send_file @writer.render) : (body @writer.render)
end

# toggles a person from the set.
get '/peopleset/:set_id/toggle/:person_id' do
    @peopleset = Peopleset.find(params[:set_id])
    @peopleset.toggle Person.find(params[:person_id])
    @people = @peopleset.get_people
    partial :"view/peopleset"
end

# adds or removes all the visible people on a table from the current set.
post '/people/:action' do
	@peopleset = get_current_peopleset
	case params[:action]
			when "select" then @peopleset.add_people params[:person_id].keys
			when "clear" then @peopleset.remove_people params[:person_id].keys
	end
	redirect "/people/peopleset/#{@peopleset.id}/view"
end