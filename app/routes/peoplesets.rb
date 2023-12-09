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
    puts "got params #{params}".yellow
    @peopleset = Peopleset.find(params[:id])
    @people = @peopleset.get_people
    @peopleset.edit(params[:att_name], params[params[:att_name]])
    partial :"view/peopleset"
end

# word. 
# TODO
get '/people/current_set/F28' do
    
    content_type 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    @people = get_current_peopleset.get_people()
    puts "Current dir #{Dir.pwd}"
    file = WordDocCreator.F28 ({path: "tmp/F28.docx", people: @people})
    puts "pwd: #{Dir.pwd}"
    puts "filepath: #{file.path}"
    send_file file.path, disposition: 'attachment'#, filename: "F28.docx"
end

# exports the set to excel
get '/people/peopleset/:id/export/excel' do
    
    exporter = Excelexporter.new(Peopleset.find(params[:id]).get_people)
    send_file exporter.get_file_path, :disposition => 'attachment', :type => 'application/excel', :filename => "lista_alumnos.xlsx"
end

# renders the form for the reports that do not need additional info
get '/people/peopleset/:id/report/:report' do
    
    content_type 'application/pdf'
    people = Peopleset.find(params[:id]).get_people
    PDFReport.new(people: people, document_type: params[:report]).render
end

# renders the form for the reports that need some info to be rendered
get '/people/peopleset/:id/report/:report/form' do
    
    @peopleset = Peopleset.find(params[:id])
    @report = params[:report]
    partial :"form/report"
end

# renders a pdf with the params received.
get '/people/peopleset/:set_id/document/:doc_id' do
    
    @peopleset = Peopleset.find(params[:set_id])
    @people = @peopleset.get_people
    @document = Document.find(params[:doc_id])
    ##pw = Pandoc_Writer.new("app/pandoc/#{@document.path}", @people)
    status 200
    case @document.engine
        when "pandoc"
            headers 'content-type' => "application/pdf"
            body @document.render(@people)
        when "excel"
            headers 'content-type' => "html"
            send_file @document.render(@people), :filename => "#{@document.name}.xlsx"
        end
    
end


# renders a pdf with the params received.
post '/people/peopleset/:id/report/:report/form' do
    
    @peopleset = Peopleset.find(params[:id])
    @people = @peopleset.get_people
    content_type 'application/pdf'
    PDFReport.new(people: @people, date: params[:date], document_type: params[:report]).render
end

# toggles a person from the set.
get '/peopleset/:set_id/toggle/:person_id' do
    
    puts "got current set: #{get_current_peopleset.get_name}".yellow
    @peopleset = Peopleset.find(params[:set_id])
    @peopleset.toggle Person.find(params[:person_id])
    @people = @peopleset.get_people
    partial :"view/peopleset"
end