########################################################################################
# ROUTES CONTROLLERS FOR THE VELA OBJECT
########################################################################################
require"clipboard"

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
get '/vela/:id/turnos' do
  @vela = Vela.find(params[:id])
  @vela.update_from_params params
  @turnos = @vela.build_turnos
  partial :"frame/turnos"
end

# copies tghe current query results to the clipboard
# TODO should catch some possible errors from the Cipboard.copy call
get '/vela/:id/clipboard/copy' do
  @vela = Vela.find(params[:id])
	Clipboard.copy @vela.to_csv
	{result: true}.to_json
end


# renders a single document form
get '/vela/:id/pdf' do
  headers 'content-type' => "application/pdf"
  @vela = Vela.find(params[:id])
  result = @vela.to_pdf (@vela.build_turnos)
  OS.windows? ? (send_file @writer.render) : (body result)
end

# renders a single document form
get '/vela/:id' do
  @object = (params[:id]=="new" ? Vela.create_new() : Vela.find(params[:id]))
  partial :"form/vela"
end


########################################################################################
# POST ROUTES
########################################################################################
post '/vela/:id' do
  @vela = (params[:id]=="new" ? nil : Vela.find(params[:id]))
  case params[:commit]
    when "save"     
      if @vela.nil? 
        @vela = Vela.create_from_params params
      else
      	res = @vela.update_from_params params
        check_update_result res
      end
    # if a person was deleted we go back to the screen fo the people table
    when "delete" then @vela.destroy
  end
  redirect '/velas/frame'
end