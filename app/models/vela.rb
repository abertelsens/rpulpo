# vela.rb
# ---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-09-25
# ---------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------
# DESCRIPTION

# An class defining a vela object
# ---------------------------------------------------------------------------------------

# requires the engines path in order to have access to the typst engine.
require_rel '../engines'

class Vela < ActiveRecord::Base

	# each vela has many turnos which are destroyed when the parent vela object is destroyed
	has_many :turnos,  dependent: :destroy

	# the default scoped defines the default sort order of the query results
	default_scope { order(date: :asc) }

	# ---------------------------------------------------------------------------------------
	# CLASS CONSTANTS
	# ---------------------------------------------------------------------------------------

	TYPST_TEMPLATES_DIR = "app/engines-templates/typst"
	TYPST_PREAMBLE_SEPARATOR = "//CONTENTS"
	HALF_HOUR = 30*60 #in seconds
	DEFAULT_ORDER = "0 1 2 3 4 5"
	DEFAULT_MSG_1 =  "Examen"
	DEFAULT_MSG_2 = "Exposición en Nuestra Señora de los Ángeles"
	DEFAULT_END_MSG = "Bendición y Santa Misa en Nuestra Señora de los Ángeles"


	# creates a vela objet with default parameters
	def self.create_new()
		today = DateTime.now
		tomorrow = today + 1
		params =
		{
			date: 					today,
			start_time:			parse_datetime(today,21,00),
			start_time2:		parse_datetime(today,21,15),
			end_time:				DateTime.new(tomorrow.year, tomorrow.month, tomorrow.day, 6, 30, 0,1),
			start1_message: DEFAULT_MSG_1,
			start2_message: DEFAULT_MSG_2,
			end_message:		DEFAULT_END_MSG,
			order: 					DEFAULT_ORDER,
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
		current_time = start_time2 + 15*60 # 15 minutes after start_time2, i.e. the Exposition
		puts "current time #{current_time} end time #{end_time}"
		while current_time < end_time do
			turnos << Turno.create(vela: self, start_time: current_time, end_time: current_time + HALF_HOUR )
			current_time = current_time + HALF_HOUR
		end
		assign_turnos((Room.get_from_houses houses).order(room: :asc))
	end

	def assign_turnos(rooms)
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

		turnos_table = VelaDecorator.new(self).turnos_to_typst_table

		full_doc = "#{template_source[0]} #{header} #{turnos_table}\n #{footer}"

		# delete all the previous pdf files. Not ideal
		# write a tmp typst file and compile it to pdf
		Dir.glob("#{TYPST_TEMPLATES_DIR}/*.tmp.typ").each {|file| File.delete file}
		Dir.glob("#{TYPST_TEMPLATES_DIR}/*.tmp.pdf").each {|file| File.delete file}
		tmp_file_name = rand(10000).to_s
		typ_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.tmp.typ"
		pdf_file_path = "#{TYPST_TEMPLATES_DIR}/#{tmp_file_name}.tmp.pdf"

		File.write typ_file_path, full_doc
		res =  system("typst compile #{typ_file_path} #{pdf_file_path}")
		res ? pdf_file_path : "Typst Writer: failed to convert document"

	end


	def self.parse_datetime(date,hour,min)
		DateTime.new(date.year, date.month, date.day,hour,min,0,1)
	end

end #class end
