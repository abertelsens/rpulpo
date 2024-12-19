# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE VELAS TABLES
# -----------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------
# GET
# -----------------------------------------------------------------------------------------

# renders the documents frame
get '/velas' do
  @current_user = get_current_user
  partial :"frame/simple_template",  locals: {title: "VELAS AL SANTÍSIMO", model_name: "vela", table_name: "velas" }
end

# renders the table of documents
# @objects - the documents that will be shown in the table
get '/velas/table' do
  @objects = Vela.all
  partial :"table/velas"
end


post '/vela/:id/turnos/update' do
  #puts "UPDATING TURNOS"
  @vela = Vela.find(params[:id])
  @vela.update_from_params params
  @vela.turnos.destroy
  @vela.build_turnos
  @turnos = @vela.turnos.includes(:rooms => [:person])
  partial :"frame/turnos"
end

# renders a single document form
get '/vela/:id/turnos' do
  @vela = Vela.find(params[:id])
  @turnos = @vela.turnos.includes(:rooms => [:person])
  partial :"frame/turnos"
end


# renders a single document form
get '/vela/:id/pdf' do
  headers 'content-type' => "application/pdf"
  send_file (Vela.find(params[:id])).to_pdf
end

# renders a single document form
get '/vela/:id' do
  @object = (params[:id]=="new" ? Vela.create_new() : Vela.find(params[:id]))
  @object.build_turnos if @object.turnos.empty?
  partial :"form/vela"
end

# -----------------------------------------------------------------------------------------
# POST
# -----------------------------------------------------------------------------------------
post '/vela/:id' do
  #puts "POST IN VELA\n\n\n"
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
  redirect '/velas'
end

# -----------------------------------------------------------------------------------------
# DRAG AND DROP OF TURNOS
# -----------------------------------------------------------------------------------------
get '/vela/:id/update_drag' do
  @vela = Vela.find(params[:id])
  @turnos = @vela.turnos.includes(:rooms => [:person])
  partial :"frame/turnos"

end

post '/vela/:id/turno/:turno_id/room/:room_id' do
  @vela = Vela.find(params[:id])
  room = Room.find(params[:room_id])
  old_turno = @vela.turnos.find{|turno| turno.rooms.include? room}
  TurnoRoom.find_by(turno: old_turno, room: room).update(turno_id: params[:turno_id])
end

post '/vela/:id/turno/:turno_id/room/:room_id/delete' do
  @vela = Vela.find(params[:id])
  room = Room.find(params[:room_id])
  turno = @vela.turnos.find{|turno| turno.rooms.include? room}
  TurnoRoom.find_by(turno: turno, room: room).destroy
end
