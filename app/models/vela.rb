
require_rel '../engines'
require 'os'
require 'typst' if OS.mac?

#A class containing the Users data
class Vela < ActiveRecord::Base

TYPST_TEMPLATES_DIR = "app/engines-templates/typst"
TYPST_PREAMBLE_SEPARATOR = "//CONTENTS"

	def self.prepare_params(params)
		date = Date.parse params[:date]
		{
			date: 					date,
			start_time:			DateTime.new(date.year, date.month, date.day, params[:start_time_hour].to_i, params[:start_time_min].to_i,0,1),
			start_time2:		DateTime.new(date.year, date.month, date.day, params[:start_time2_hour].to_i , params[:start_time2_min].to_i,0,1),
			end_time:				DateTime.new(date.year, date.month, date.day + 1, params[:end_time_hour].to_i, params[:end_time_min].to_i, 0,1),
			start1_message: params[:start1_message],
			start2_message: params[:start2_message],
			end_message: 		params[:end_message],
			order: 					params[:house].values.join(" ")
		}
	end

	def self.create_from_params(params)
		Vela.create (Vela.prepare_params params)
	end

	def order_to_s
		houses_names = Room.houses.keys
		order.split(" ").select{|index| index!="-1"}.map{|index| houses_names[index.to_i].humanize}.join( " - " )
	end

	def self.create_new()
		date = DateTime.now()
		params =
		{
			date: 					date,
			start_time:			DateTime.new(date.year, date.month, date.day, 21, 15 ,0, 1),
			start_time2:		DateTime.new(date.year, date.month, date.day, 21, 30 ,0, 1),
			end_time:				DateTime.new(date.year, date.month, date.day + 1, 6, 30, 0,1),
			start1_message: "Examen",
			start2_message: "Exposición en Nuestra Señora de los Ángeles",
			end_message:		"Exposición en Nuestra Señora de los Ángeles",
			order: 					"0 1 2 3 4 5",
		}
		Vela.create params
	end

	def update_from_params(params)
		update(Vela.prepare_params params)
	end

	def build_turnos
		houses = order.split(" ").select{|index| index!="-1"}
		rooms = Room.get_from_houses houses
		current_time = self.start_time2
		half_hour = 30*60 #1.0/(24*2)
		turnos = []

		while current_time < self.end_time do
			turnos << Turno.new(current_time , current_time + half_hour)
			current_time = current_time + half_hour
		end
		assign_turnos(turnos,rooms)
	end

	def assign_turnos(turnos, rooms)
		primer_turno = rooms.select{|room| room.person.vela=="primer_turno"}
		ultimo_turno = rooms.select{|room| room.person.vela=="ultimo_turno"}
		no_vela = rooms.select{|room| room.person.vela=="no"}

		turnos[0].assign primer_turno
		turnos[-1].assign ultimo_turno

		rooms = ((rooms - primer_turno) - ultimo_turno) - no_vela
		turnos_left = turnos.size

		turnos.each_with_index do |turno,index|
			people_to_assing = ((rooms.size.to_f/turnos_left).round).to_i

			if turno.empty?
				turno.assign rooms[0..(people_to_assing-1)]
			else
				people_in_turno = turno.rooms.size
				people_to_assing = [0,people_to_assing-people_in_turno].max
				turno.assign rooms[0..(people_to_assing - 1)]  if people_to_assing > 0
			end
			turnos_left = turnos_left -1
			rooms = rooms - turno.rooms
	end
	end

	def to_csv
		turnos = build_turnos
		header = "#{self.start_time.strftime('%H:%M')}:\t#{self.start1_message}\n#{self.start_time2.strftime('%H:%M')}:\t#{self.start2_message}\n"
		footer = 	"\n#{self.end_time.strftime('%H:%M')}:\t#{self.end_message}"
		turnos_table = Turno.to_csv turnos
		full_doc = "#{header}\n#{turnos_table}\n#{footer}"
	end

	def to_pdf turnos
		turnos = build_turnos

		@document_path = "vela.typ"
		@template_source = File.read "#{TYPST_TEMPLATES_DIR}/#{@document_path}"
		template_source = @template_source.split(TYPST_PREAMBLE_SEPARATOR)

		header = "= vela al santísimo (#{self.date.strftime('%d %b %y').downcase})\n
							*#{self.start_time.strftime('%H:%M')}: #{self.start1_message}*\n
							*#{self.start_time2.strftime('%H:%M')}: #{self.start2_message}*\n"

		footer = 	"*#{self.end_time.strftime('%H:%M')}: #{self.end_message}*"

		turnos_table = Turno.to_typst_table turnos

		full_doc = "#{template_source[0]} #{header} #{turnos_table}\n #{footer}"



		if OS.windows?
			# delete all the previous pdf files. Not ideal
			# write a tmp typst file and compile it to pdf
			FileUtils.rm Dir.glob("#{TYPST_TEMPLATES_DIR}/*.pdf")
			tmp_file_name ="#{rand(10000)}"
			typ_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.typ"
			pdf_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.pdf"

			File.write typ_file_path, full_doc
			res =  system("typst compile #{typ_file_path} #{pdf_file_path}")
			File.delete typ_file_path
			res ? (return pdf_file_path) : set_error(FATAL, "Typst Writer: failed to convert document: #{error.message}")
		else
			return Typst::Pdf.from_s(full_doc).document
		end

	end

	def self.turno2table(turno)
		res = ""
		turno[2].each_with_index do |room,index|
			res << "[ #{(index==0 ? "#{turno[0].strftime('%H:%M')}\t -\t #{turno[1].strftime('%H:%M')}" : "")} ], [#{room.person.short_name}], [#{room.room}],"
		end
		return res
	end
end #class end


class Turno

	attr_accessor :rooms, :stime, :etime

	def initialize(start_time, end_time)
		@stime = start_time
		@etime = end_time
		@rooms = []
	end

	def assign(rooms)
		@rooms += rooms
	end

	def empty?
		@rooms.empty?
	end

	def get_time(args)
	 	case args
			when :start then @stime.strftime('%H:%M')
			when :end 	then @etime.strftime('%H:%M')
		end
	end

	def to_typst_table
		res = ""
		@rooms.each_with_index do |room, index|
			if index!=0
				res << "[], [#{room.person.short_name}], [#{room.room}]"
			else
				res << "[#{@stime.strftime('%H:%M')} - #{@etime.strftime('%H:%M')}], [#{room.person.short_name}], [#{room.room}]"
			end
			res << ", " if index < @rooms.size-1
		end
		res
	end

	def to_csv
		res = ""
		@rooms.each_with_index do |room, index|
			if index!=0
				res << "\n\t#{room.person.short_name}\t#{room.room}"
			else
				res << "#{@stime.strftime('%H:%M')} - #{@etime.strftime('%H:%M')}\t#{room.person.short_name}\t#{room.room}"
			end
		end
		res
	end

	def self.to_typst_table(turnos)
		table_header = "#table(\ncolumns: (auto, auto, auto),\ninset: (x:20pt, y:5pt),\nstroke: none,\nalign: horizon,\n"
		table_header << (turnos.map{|turno| turno.to_typst_table}).join(",\n") <<")\n"
	end

	def self.to_csv(turnos)
		(turnos.map{|turno| turno.to_csv}).join("\n")
	end

end #class end
