
require_rel '../engines'

class Vela < ActiveRecord::Base

	has_many :turnos,  dependent: :destroy

	# the default scoped defines the default sort order of the query results
	default_scope { order(date: :asc) }

	TYPST_TEMPLATES_DIR = "app/engines-templates/typst"
	TYPST_PREAMBLE_SEPARATOR = "//CONTENTS"
	HALF_HOUR = 30*60 #in seconds

	# creates a vela objet with default parameters
	def self.create_new()
		date = DateTime.now()
		params =
		{
			date: 					date,
			start_time:			parse_datetime(date,21,05),
			start_time2:		parse_datetime(date,21,20),
			end_time:				DateTime.new(date.year, date.month, date.day + 1, 6, 30, 0,1),
			start1_message: "Examen",
			start2_message: "Exposición en Nuestra Señora de los Ángeles",
			end_message:		"Bendición y Santa Misa en Nuestra Señora de los Ángeles",
			order: 					"0 1 2 3 4 5",
		}
		Vela.create params
	end

	def self.prepare_params(params)
		date = Date.parse params[:date]
		{
			date: 					date,
			start_time:			parse_datetime(date, params[:start_time_hour].to_i, params[:start_time_min].to_i),
			start_time2:		parse_datetime(date, params[:start_time2_hour].to_i, params[:start_time2_min].to_i),
			end_time:				parse_datetime(date.next_day(1), params[:end_time_hour].to_i, params[:end_time_min].to_i),
			start1_message: params[:start1_message],
			start2_message: params[:start2_message],
			end_message: 		params[:end_message],
			order: 					params[:house].values.join(" ")
		}
	end

	def update_from_params(params)
		update(Vela.prepare_params params)
	end

	def order_to_s
		houses_names = Room.houses.keys
		order.split(" ").select{|index| index!="-1"}.map{|index| houses_names[index.to_i].humanize}.join( " - " )
	end

	# buils all the turnos for the vela
	def build_turnos

		turnos.destroy_all unless turnos.nil?
		houses = order.split(" ").select{|index| index!="-1"}
		current_time = start_time2 + 10*60 # 10 minutes after start_time2, i.e. the Exposition

		puts "building turnos for times #{current_time} and  #{end_time}"
		while current_time < end_time do
			turnos << Turno.create(vela: self, start_time: current_time, end_time: current_time + HALF_HOUR )
			current_time = current_time + HALF_HOUR
		end
		assign_turnos((Room.get_from_houses houses).order(room: :asc))
	end

	def assign_turnos(rooms)
		no_vela = rooms.select{|room| room.person.vela=="no"}
		assign(turnos.to_a,rooms)
	end

	def assign(turnos2assign, rooms)
		slots_number = turnos2assign.size
		rooms_to_assign = rooms[0..(rooms.size/slots_number).to_i-1]
		turnos2assign[0].rooms << rooms_to_assign
		assign(turnos2assign.drop(1),rooms - rooms_to_assign) unless slots_number==1
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


	def self.parse_datetime(date,hour,min)
		DateTime.new(date.year, date.month, date.day,hour,min,0,1)
	end
end #class end
