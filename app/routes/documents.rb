########################################################################################
# ROUTES CONTROLLERS FOR THE PEOPLE TABLES
########################################################################################

# renders the people frame
get '/documents/frame' do
    print_controller_log
    partial :"frame/documents"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/documents/table' do
    print_controller_log
    @objects = Document.get_docs_of_user get_current_user
    partial :"table/documents"
end

# renders a single document view
get '/document/:id' do
    @object = (params[:id]=="new" ? nil : Document.find(params[:id]))
    puts "OBJECT #{@object.nil?}"
    partial :"form/document"
end

# renders a single document view
get '/document/:id/viewtemplate' do
    @document = (params[:id]=="new" ? nil : Document.find(params[:id]))
    File.read @document.get_full_path
end


########################################################################################
# POST ROUTES
########################################################################################
post '/document/:id' do
    print_controller_log
    @document = (params[:id]=="new" ? nil : Document.find(params[:id]))
    case params[:commit]
        when "save"     
            if @document.nil? 
                @document = Document.create_from_params params
            else
                res = @document.update_from_params params
                check_update_result res
            end
        # if a person was deleted we go back to the screen fo the people table
        when "delete" then @document.destroy
    end
    redirect '/documents/frame'

end