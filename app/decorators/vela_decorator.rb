

class VelaDecorator
  def initialize(vela)
    @vela = vela
  end

  def turnos_to_typst_table()
		header = "#table(
			columns: (auto, auto, auto),
			inset: (x:20pt, y:5pt),
			stroke: none,
			align: horizon,\n"
    @vela.turnos.order(start_time: :asc).inject(header){|res,turno| res << turno.toTypstTable << ",\n"} <<  ")"
	end


end


class TurnoDecorator

  def initialize(turno)
    @turno = turno
  end

  def toTypstTable()
		rooms_list = @turno.rooms.order(room: :asc) unless @turno.rooms.nil?
		return emptyTurno() if rooms_list.empty?
		rooms_list.drop(1).inject(formatRoom(rooms_list[0], true)){|res, room| res << ",\n" << formatRoom(room)  }
  end

  def emptyTurno()
    "[#{formatTime(@turno.start_time)} - #{formatTime(@turno.end_time)}],[-], [-]"
  end

  def formatRoom(room, first_room=false)
    if first_room
      "[#{formatTime(@turno.start_time)} - #{formatTime(@turno.end_time)}],[#{room.person&.short_name}], [#{room.room}]"
    else
      "[],[#{room.person&.short_name}], [#{room.room}]"
    end
  end

  def formatTime(time)
    time.strftime('%H:%M')
  end
end
