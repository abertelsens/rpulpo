require 'prawn'
require 'prawn/table'

LINE_HEIGHT = 24

class PrawnWriter  < DocumentWriter

	def initialize(document, people)
		case document.name
			when "C38" then self.create_C38(people)
		end
	end

	def render
		@pdf.render
	end

	def write_file(file_path)
		@pdf.render_file file_path
	end

	#=====================================================================================================================
	# C38
	#=====================================================================================================================

	def create_C38(people)
		@pdf = Prawn::Document.new(:page_size => 'A5', page_layout: :landscape, :margin => [36,36,36,36])
		people.each_with_index do |person, index|
			c38_page person
			@pdf.start_new_page if index+1 < people.size()
		end
	end

	def c38_page(person)
		@person = person
		@personal = Personal.find_by(person_id: person.id)
		@study = Study.find_by(person_id: person.id)
		@crs = Crs.find_by(person_id: person.id)
		puts "generating pdf of #{@person.full_name}"
		#margins are in inches
		@pdf.font('Times-Roman', size: 10)

		@pdf.bounding_box([0, @pdf.cursor], width: 110, height: 135) do
				#@pdf.stroke_bounds
				@pdf.image "app/public/photos/#{@person.id}.jpg", position: :left, :height => 135 if File.file?("app/public/photos/#{@person.id}.jpg")
		end

		@pdf.bounding_box([135, @pdf.cursor+135], width: 388, height: 155) do
				#@pdf.stroke_bounds
			@pdf.font('Times-Roman', size: 10)
			@pdf.move_up 15
			@pdf.text "Colegio Romano de la Santa Cruz", :size => 10, :style => :italic, color: '0c418c', align: :right
			@pdf.move_down 15
			@pdf.font('Helvetica', size: 18, :style => :bold)
			@pdf.text "#{@person.family_name}, #{@person.first_name}", :size => 16, align: :left
			@pdf.stroke_color '0c418c'
			@pdf.stroke_horizontal_rule

			@pdf.move_down LINE_HEIGHT
			add_label("Alumno del Colegio desde",0,@pdf.cursor+LINE_HEIGHT,160,LINE_HEIGHT)
			add_field("#{@person.arrival&.strftime("%m-%d-%Y")}" ,160 , @pdf.cursor+LINE_HEIGHT, 80, LINE_HEIGHT) unless @person.nil?

			add_label("hasta",240,@pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
			add_field("#{@person.departure&.strftime("%d-%m-%Y")}" ,320 , @pdf.cursor+LINE_HEIGHT, 68, LINE_HEIGHT) unless @person.nil?
			@pdf.move_down LINE_HEIGHT

			add_label("Promoción no.",0,@pdf.cursor+LINE_HEIGHT,160,LINE_HEIGHT)
			add_field("#{@crs&.classnumber}" ,160 , @pdf.cursor+LINE_HEIGHT, 228, LINE_HEIGHT)
			@pdf.move_down LINE_HEIGHT

			add_label("Región de Origen",0,@pdf.cursor+LINE_HEIGHT,160,LINE_HEIGHT)
			add_field("#{@personal.region_of_origin}" ,160 , @pdf.cursor+LINE_HEIGHT, 80, LINE_HEIGHT)  unless @personal.nil?

			add_label("Región",240,@pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
			add_field("#{@personal.region}" ,320 , @pdf.cursor+LINE_HEIGHT, 68, LINE_HEIGHT) unless @personal.nil?
			@pdf.move_down LINE_HEIGHT

			add_label("Alumno del Colegio Mayor Aralar",0,@pdf.cursor+LINE_HEIGHT,160,LINE_HEIGHT)
			add_field("#{@crs&.cipna}" ,160 , @pdf.cursor+LINE_HEIGHT, 228, LINE_HEIGHT) unless @crs.nil?
			@pdf.move_down LINE_HEIGHT

			add_label("Lugar y Fecha de Nacimiento",0,@pdf.cursor+LINE_HEIGHT,160,LINE_HEIGHT)
			add_field("#{@person.birth&.strftime("%d-%m-%Y")}" ,160 , @pdf.cursor+LINE_HEIGHT, 228, LINE_HEIGHT) unless @person.nil?
		end

		@pdf.move_down LINE_HEIGHT

		add_label("Estudios Institucionales", 0,@pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
		add_field("#{@study.status}" ,135 , @pdf.cursor+LINE_HEIGHT, 388, LINE_HEIGHT) unless @study.nil?

		@pdf.move_down LINE_HEIGHT

		add_label("Estudios Civiles", 0,@pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
		add_field("#{@study.civil_studies}" ,135 , @pdf.cursor+LINE_HEIGHT, 388, LINE_HEIGHT) unless @study.nil?
		@pdf.move_down LINE_HEIGHT

		add_label("Facultad Eclesiástica", 0,@pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
		add_field("#{@study.faculty}" ,135 , @pdf.cursor+LINE_HEIGHT, 120, LINE_HEIGHT) unless @study.nil?

		add_label("Licenciatura", 255, @pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
		add_field("#{@study.licence}" ,335 , @pdf.cursor+LINE_HEIGHT, 60, LINE_HEIGHT) unless @study.nil?

		add_label("Doctorado", 395, @pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
		add_field("#{@study.doctorate}" ,475 , @pdf.cursor+LINE_HEIGHT, 48, LINE_HEIGHT) unless @study.nil?
		@pdf.move_down LINE_HEIGHT

		add_label("Tesis Doctoral", 0, @pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
		add_field("#{@study.thesis}" ,135 , @pdf.cursor+2*LINE_HEIGHT, 388, 2*LINE_HEIGHT) unless @study.nil?
		@pdf.move_down LINE_HEIGHT

		add_label("Idiomas", 0, @pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
		add_field("#{@personal.languages}" ,135 , @pdf.cursor+LINE_HEIGHT, 388, LINE_HEIGHT) unless @personal.nil?
		@pdf.move_down LINE_HEIGHT

		add_label("Pidió la admisión", 0, @pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
		add_field("#{@crs.pa&.strftime("%d-%m-%Y")}" ,135 , @pdf.cursor+LINE_HEIGHT, 120, LINE_HEIGHT) unless @crs.nil?

		add_label("Hizo la Oblación", 255, @pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
		add_field("#{@crs.oblacion&.strftime("%d-%m-%Y")}" ,335 , @pdf.cursor+LINE_HEIGHT, 188, LINE_HEIGHT) unless @crs.nil?
		@pdf.move_down LINE_HEIGHT

		add_label("Hizo la Admisión", 0, @pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
		add_field("#{@crs.admision&.strftime("%d-%m-%Y")}" ,135 , @pdf.cursor+LINE_HEIGHT, 120, LINE_HEIGHT) unless @crs.nil?

		add_label("Hizo la Fidelidad", 255, @pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
		add_field("#{@crs.fidelidad&.strftime("%d-%m-%Y")}" ,335 , @pdf.cursor+LINE_HEIGHT, 188, LINE_HEIGHT) unless @crs.nil?

		@pdf.start_new_page
		@pdf.move_down LINE_HEIGHT

		add_label("Ha manifestado su disposición de ser sacerdote", 0, @pdf.cursor+LINE_HEIGHT,235,LINE_HEIGHT)
		add_field("#{@crs.letter&.strftime("%d-%m-%Y")}" ,235 , @pdf.cursor+LINE_HEIGHT, 100, LINE_HEIGHT) unless @crs.nil?

		add_label("Hizo la Admissio", 335, @pdf.cursor+LINE_HEIGHT,100,LINE_HEIGHT)
		add_field("#{@crs.admissio&.strftime("%d-%m-%Y")}" ,435 , @pdf.cursor+LINE_HEIGHT, 85, LINE_HEIGHT) unless @crs.nil?
		@pdf.move_down LINE_HEIGHT


		add_label("Recibió el Lectorado", 0, @pdf.cursor+LINE_HEIGHT,235,LINE_HEIGHT)
		add_field("#{@crs.lectorado&.strftime("%d-%m-%Y")}" ,235 , @pdf.cursor+LINE_HEIGHT, 100, LINE_HEIGHT) unless @crs.nil?

		add_label("Recibió el Acolitado", 335, @pdf.cursor+LINE_HEIGHT,100,LINE_HEIGHT)
		add_field("#{@crs.acolitado&.strftime("%d-%m-%Y")}" ,435 , @pdf.cursor+LINE_HEIGHT, 85, LINE_HEIGHT) unless @crs.nil?
		@pdf.move_down LINE_HEIGHT

		add_label("Ordenado Diácono", 0, @pdf.cursor+LINE_HEIGHT,235,LINE_HEIGHT)
		add_field("#{@crs.diaconado&.strftime("%d-%m-%Y")}" ,235 , @pdf.cursor+LINE_HEIGHT, 100, LINE_HEIGHT) unless @crs.nil?

		add_label("Ordenado Sacerdote", 335, @pdf.cursor+LINE_HEIGHT,100,LINE_HEIGHT)
		add_field("#{@crs.presbiterado&.strftime("%d-%m-%Y")}" ,435 , @pdf.cursor+LINE_HEIGHT, 85, LINE_HEIGHT) unless @crs.nil?
		@pdf.move_down LINE_HEIGHT

		add_label("Datos y Circunstacias Familiares", 0, @pdf.cursor+LINE_HEIGHT,235,LINE_HEIGHT)
		@pdf.move_down LINE_HEIGHT
		add_field("Padres: #{@personal.father_name} y #{@personal.mother_name}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT) unless @personal.nil?
		@pdf.move_down LINE_HEIGHT
		add_field("Domicilio: #{@personal.parents_address}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT) unless @personal.nil?
		@pdf.move_down LINE_HEIGHT
		add_field("#{@personal.siblings_info}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT) unless @personal.nil?
		@pdf.move_down LINE_HEIGHT
		add_field("#{@personal.parents_info}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT) unless @personal.nil?
		@pdf.move_down LINE_HEIGHT
		add_field("#{@personal.parents_work}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT) unless @personal.nil?
		@pdf.move_down LINE_HEIGHT
		add_field("#{@personal.economic_info}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT) unless @personal.nil?

		@pdf.move_down LINE_HEIGHT

		add_label("Antecedentes Médicos", 0, @pdf.cursor+LINE_HEIGHT,140,LINE_HEIGHT)
		add_field("#{@personal.medical_info}" ,140 , @pdf.cursor+1.5*LINE_HEIGHT, 385, 1.5*LINE_HEIGHT) unless @personal.nil?
		@pdf.move_down LINE_HEIGHT

		add_label("Observaciones", 0, @pdf.cursor+LINE_HEIGHT,140,1.5*LINE_HEIGHT)
		add_field("#{@personal.notes}" ,140 , @pdf.cursor+1.5*LINE_HEIGHT, 385, 1.5*LINE_HEIGHT) unless @personal.nil?

		@pdf.move_down 1.5*LINE_HEIGHT

		@pdf.font('Times-Roman', size: 8)
		@pdf.text "C 38", align: :left

	end

	def add_paragraph(text)
		@pdf.text text, indent_paragraphs: 20, align: :justify
		@pdf.move_down 10
	end

	def add_label(text,x,y,width,height)
			@pdf.bounding_box([x, y], width: width, height: height) do
					#@pdf.stroke_bounds
					@pdf.font('Times-Roman', size: 10)
					@pdf.text text, valign: :bottom, :style => :bold_italic, color: '0c418c', align: :left
			end
	end

	def add_field(text,x,y,width,height)
			@pdf.bounding_box([x, y], width: width, height: height) do
					#@pdf.stroke_bounds
					@pdf.font('Helvetica', size: 9)
					@pdf.text (text.encode("Windows-1252", invalid: :replace, undef: :replace, replace: '')), valign: :bottom, :style => :bold, align: :left

			end
	end

end #class end
