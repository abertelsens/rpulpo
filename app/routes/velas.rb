########################################################################################
# ROUTES CONTROLLERS FOR THE VELA OBJECT
########################################################################################


# renders the documents frame
get '/velas/frame' do
  partial :"frame/velas"
end

# renders the table of documents
# @objects - the documents that will be shown in the table
get '/velas/table' do
  @objects = Vela.all
  partial :"table/velas"
end

# renders a single document form
get '/vela/:id' do
  @object = (params[:id]=="new" ? nil : Vela.find(params[:id]))
  partial :"form/vela"
end


########################################################################################
# POST ROUTES
########################################################################################
post '/vela/:id' do
  @vela = (params[:id]=="new" ? nil : Vela.find(params[:id]))
  case params[:commit]
    when "save"     
      if @document.nil? 
        @document = Vela.create_from_params params
      else
      	res = @vela.update_from_params params
        check_update_result res
      end
    # if a person was deleted we go back to the screen fo the people table
    when "delete" then @vela.destroy
  end
  redirect '/velas/frame'
end