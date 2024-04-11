
require_rel '../engines'

#A class containing the Users data
class Vela < ActiveRecord::Base

has_many :turnos,  dependent: :destroy

TYPST_TEMPLATES_DIR = "app/engines-templates/typst"
TYPST_PREAMBLE_SEPARATOR = "//CONTENTS"
HALF_HOUR = 30*60 #1.0/(24*2)

	def self.prepare_params(params)
		puts "vela preparing params\n\n"
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

		turnos.destroy_all unless turnos.nil?
		houses = order.split(" ").select{|index| index!="-1"}
		current_time = self.start_time2 + 15*60 # 15 minutes after start_time2, i.e. the Exposition

		while current_time < self.end_time do
			turnos << Turno.create(vela: self, start_time: current_time, end_time: current_time + HALF_HOUR )
			current_time = current_time + HALF_HOUR
		end
		assign_turnos((Room.get_from_houses houses).order(room: :asc))
	end

	def assign_turnos(rooms)
		no_vela = rooms.select{|room| room.person.vela=="no"}
		rooms = (rooms - no_vela)
		assign(turnos.to_a,rooms)
	end

	def assign(turnos2assign, rooms)
		slots_number = turnos2assign.size
		rooms_to_assign = rooms[0..(rooms.size/slots_number).to_i-1]
		turnos2assign[0].rooms << rooms_to_assign
		assign(turnos2assign.drop(1),rooms - rooms_to_assign) unless slots_number==1
	end

	def to_csv
		turnos = build_turnos
		header = "#{self.start_time.strftime('%H:%M')}:\t#{self.start1_message}\n#{self.start_time2.strftime('%H:%M')}:\t#{self.start2_message}\n"
		footer = 	"\n#{self.end_time.strftime('%H:%M')}:\t#{self.end_message}"
		turnos_table = Turno.to_csv turnos
		full_doc = "#{header}\n#{turnos_table}\n#{footer}"
	end

	def to_pdf

		@document_path = "vela.typ"
		@template_source = File.read "#{TYPST_TEMPLATES_DIR}/#{@document_path}"
		template_source = @template_source.split(TYPST_PREAMBLE_SEPARATOR)

		header = "#figure(image(\"cb_icon.png\", width: 30pt),)\n
							= Vela al Santísimo - (#{self.date.strftime('%-A %-d %B %Y').downcase})\n
							*#{start_time.strftime('%H:%M')}: #{start1_message}*\n
							*#{start_time2.strftime('%H:%M')}: #{start2_message}*\n
							"

		footer = 	"*#{self.end_time.strftime('%H:%M')}: #{end_message}*"
		turnos_table = turnos2table
		full_doc = "#{template_source[0]} #{header} #{turnos_table}\n #{footer}"

		# delete all the previous pdf files. Not ideal
		# write a tmp typst file and compile it to pdf
		FileUtils.rm Dir.glob("#{TYPST_TEMPLATES_DIR}/*.pdf")
		tmp_file_name ="#{rand(10000)}"
		typ_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.typ"
		pdf_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.pdf"

		File.write typ_file_path, full_doc
		res =  system("typst compile #{typ_file_path} #{pdf_file_path}")
		#File.delete typ_file_path
		res ? (return pdf_file_path) : set_error(FATAL, "Typst Writer: failed to convert document: #{error.message}")

	end

	def turnos2table()
		res = "#table(
			columns: (auto, auto, auto),
			inset: (x:20pt, y:5pt),
			stroke: none,
			align: horizon,\n"
			res << (turnos.order(start_time: :asc).map{|turno| turno.toTypstTable}).join(",\n")
			res << ")"
	end
end #class end
