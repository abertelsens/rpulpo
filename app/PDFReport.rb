require 'prawn'

LINE_HEIGHT = 24
MONTHS_LATIN = ["Ianuarius", "Februarius", "Martius", "Aprilis", "Maius", "Iunius", "Iulius", "Augustus", "September", "October", "November", "December"]
 

class PDFReport
    
    def initialize(settings)
        @people = settings[:people]
        @doc_type = settings[:document_type]
        case @doc_type
            when "C38" then self.create_C38(settings[:people])
            when "F28" then self.create_F28(settings[:people], settings[:date])
            when "F21" then self.create_F21(settings[:people],settings[:date])
        end
    end
    
    def render
        return @pdf.render
    end

    def write_file(path)
        @pdf.render_file path
    end
    #=====================================================================================================================
    # F21
    #=====================================================================================================================
    
    def create_F21(people,date)
        @pdf = Prawn::Document.new(:page_size => 'A4', :margin => [150,114,114,114])
        people.each_with_index do |person, index|
            f21_page(person,date)
            @pdf.start_new_page if index+1 < people.size()
        end
    end
    
    def f21_page(person,date)
        @pdf.font_families.update('Palatino' => {normal: "app/resources/fonts/Palatino.ttc"})
        @pdf.font('Palatino', size: 16)
        add_title title: "PROFESSIO FIDEI", indent: 40, height: 100
        
        @pdf.font('Palatino', size: 12)
        add_paragraph "Ego #{person.first_name} #{person.family_name} firma fide credo et profíteor ómnia et síngula quae continéntur in Symbolo fídei, vidélicet:"
        add_paragraph "Credo in unum Deum Patrem omnipoténtem, factórem coeli et terrae, visibilium ómnium et invisibílium et in unum Dóminum Iesum Christum, Fílium Dei unigénitum, et ex Patre natum ante ómnia saécula, Deum de Deo, lumen de lúmine, Deum verum de Deo vero, génitum non factum, consubstantiálem Patri per quem ómnia facta sunt, qui propter nos hómines et propter nostram salútem descéndit de coelis, et incarnátus est de Spíritu Sancto, ex María Vírgine, et homo factus est; crucifixus etiam pro nobis sub Póntio Piláto, passus et sepúltus est; et resurréxit tértia die secúndum Scriptúras, et ascéndit in coelum, sedet ad déxteram Patris, et íterum venturus est cum glória iudicáre vivos et mórtuos, cuius regni non erit finis; et in Spíritum Sanctum Dóminum et vivificántem, qui ex Patre Filióque procédit; qui cum Patre et Fílio simul adorátur et conglorificátur qui locútus est per Prophétas; et unam sanctam cathólicam et apostólicam Ecclésiam. Confíteor unum baptísma in remissiónem peccatórum, et exspécto resurrectiónem mortuórum, et vitam ventúri saéculi. Amen."
        add_paragraph "Firma fide quoque credo ea ómnia quae in verbo Dei scripto vel trádito continentur et ab Ecclésia sive sollémni iudício sive ordinário et universáli Magistério tamquam divínitus reveláta credénda proponúntur."
        add_paragraph "Fírmiter etiam ampléctor ac retíneo ómnia et síngula quae circa doctrínam de fide vel móribus ab eádem definitíve proponuntur."
        add_paragraph "Insuper religióso voluntátis et intelléctus obséquio doctrínis adhaéreo quas sive Románus Póntifex sive Collégium episcopórum enuntiant cum Magistérium authenticum exércent etsi non definitívo actu eásdem proclamáre inténdant."
        add_document_date date
        add_document_number "F 21"
    end

    #=====================================================================================================================
    # F28
    #=====================================================================================================================
    
    def create_F28(people,date)
        @pdf = Prawn::Document.new(:page_size => 'A4', :margin => [150,114,114,114])
        people.each_with_index do |person, index|
            f28_page(person,date) 
            @pdf.start_new_page if index+1 < people.size()
        end
    end

    def f28_page(person,date)
        @pdf.font_families.update('Palatino' => {normal: "app/resources/fonts/Palatino.ttc"})
        @pdf.font('Palatino', size: 14)
        add_title title: "IUISUIURANDUM FIDELITATIS IN SUSCIPIENDO OFFICIO NOMINE ECCLESIAE EXERCENDO", indent: 40, height: 120

        @pdf.font('Palatino', size: 12)
        add_paragraph "Ego #{person.first_name} #{person.family_name} in suscipiendo officio promitto me cum catholica Ecclesia communionem semper servaturum, sive verbis a me prolatis, sive mea agendi ratione."
        add_paragraph "Magna cum diligentia et fidelitate onera explebo quibus teneor erga Ecclesiam, tum universam, tum particularem, in qua ad meum servitium, secundum iuris praescripta, exercendum vocatus sum."
        add_paragraph "In munere meo adimplendo, quod Ecclesiae nomine mihi commissum est, fidei depositum integrum servabo, fideliter tradam et illustrabo; quascumque igitur doctrinas iisdem contrarias devitabo."
        add_paragraph "Disciplinam cunctae Ecclesiae communem sequar et fovebo observantiamque cunctarum legum ecclesiasticarum, earum imprimis quae in Codice Iuris Canonici continentur, servabo."
        add_paragraph "Christiana oboedientia prosequar quae sacri Pastores, tamquam authentici fidei doctores et magistri declarant aut tamquam Ecclesiae rectores statuunt, atque Episcopis dioecesanis fideliter auxilium dabo, ut actio apostolica, nomine et mandato Ecclesiae exercenda, in eiusdem Ecclesiae communione peragatur."
        add_paragraph "Sic me Deus adiuvet et sancta Dei Evangelia, quae manibus meis tango."
        add_document_date date
        add_document_number "F 28"
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
            @pdf.image "app/public/photos/#{@person.id}.jpg", position: :left, :width => 110 if File.exists?("app/public/photos/#{@person.id}.jpg")
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
            add_field("#{@person.arrival.strftime("%m-%d-%Y")}" ,160 , @pdf.cursor+LINE_HEIGHT, 80, LINE_HEIGHT) unless @person.arrival.nil?

            add_label("hasta",240,@pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
            add_field("#{@person.departure.strftime("%d-%m-%Y")}" ,320 , @pdf.cursor+LINE_HEIGHT, 68, LINE_HEIGHT) unless @person.departure.nil?
            @pdf.move_down LINE_HEIGHT

            add_label("Promoción no.",0,@pdf.cursor+LINE_HEIGHT,160,LINE_HEIGHT)
            add_field("#{@crs.classnumber}" ,160 , @pdf.cursor+LINE_HEIGHT, 228, LINE_HEIGHT)
            @pdf.move_down LINE_HEIGHT
            
            add_label("Región de Origen",0,@pdf.cursor+LINE_HEIGHT,160,LINE_HEIGHT)
            add_field("#{@personal.region_of_origin}" ,160 , @pdf.cursor+LINE_HEIGHT, 80, LINE_HEIGHT)
            
            add_label("Región",240,@pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
            add_field("#{@personal.region}" ,320 , @pdf.cursor+LINE_HEIGHT, 68, LINE_HEIGHT)
            @pdf.move_down LINE_HEIGHT

            add_label("Alumno del Colegio Mayor Aralar",0,@pdf.cursor+LINE_HEIGHT,160,LINE_HEIGHT)
            add_field("#{@crs.cipna}" ,160 , @pdf.cursor+LINE_HEIGHT, 228, LINE_HEIGHT)
            @pdf.move_down LINE_HEIGHT
            
            add_label("Lugar y Fecha de Nacimiento",0,@pdf.cursor+LINE_HEIGHT,160,LINE_HEIGHT)
            add_field("#{@person.birth.strftime("%d-%m-%Y")}" ,160 , @pdf.cursor+LINE_HEIGHT, 228, LINE_HEIGHT) unless @person.birth.nil?
        end

        @pdf.move_down LINE_HEIGHT

        add_label("Estudios Institucionales", 0,@pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
        add_field("#{@study.status}" ,135 , @pdf.cursor+LINE_HEIGHT, 388, LINE_HEIGHT)
        @pdf.move_down LINE_HEIGHT
        
        add_label("Estudios Civiles", 0,@pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
        add_field("#{@study.civil_studies}" ,135 , @pdf.cursor+LINE_HEIGHT, 388, LINE_HEIGHT)        
        @pdf.move_down LINE_HEIGHT

        add_label("Facultad Eclesiástica", 0,@pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
        add_field("#{@study.faculty}" ,135 , @pdf.cursor+LINE_HEIGHT, 120, LINE_HEIGHT)
        
        add_label("Licenciatura", 255, @pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
        add_field("#{@study.licence}" ,335 , @pdf.cursor+LINE_HEIGHT, 60, LINE_HEIGHT) unless @study.licence.nil?
        
        add_label("Doctorado", 395, @pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
        add_field("#{@study.doctorate}" ,475 , @pdf.cursor+LINE_HEIGHT, 48, LINE_HEIGHT) unless @study.doctorate.nil?
        @pdf.move_down LINE_HEIGHT

        add_label("Tesis Doctoral", 0, @pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
        add_field("#{@study.thesis}" ,135 , @pdf.cursor+2*LINE_HEIGHT, 388, 2*LINE_HEIGHT)
        @pdf.move_down LINE_HEIGHT

        add_label("Idiomas", 0, @pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
        add_field("#{@personal.languages}" ,135 , @pdf.cursor+LINE_HEIGHT, 388, LINE_HEIGHT) 
        @pdf.move_down LINE_HEIGHT

        add_label("Pidió la admisión", 0, @pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
        add_field("#{@crs.pa.strftime("%d-%m-%Y")}" ,135 , @pdf.cursor+LINE_HEIGHT, 120, LINE_HEIGHT) unless @crs.pa.nil?

        add_label("Hizo la Oblación", 255, @pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
        add_field("#{@crs.oblacion.strftime("%d-%m-%Y")}" ,335 , @pdf.cursor+LINE_HEIGHT, 188, LINE_HEIGHT) unless @crs.oblacion.nil?
        @pdf.move_down LINE_HEIGHT

        add_label("Hizo la Admisión", 0, @pdf.cursor+LINE_HEIGHT,135,LINE_HEIGHT)
        add_field("#{@crs.admision.strftime("%d-%m-%Y")}" ,335 , @pdf.cursor+LINE_HEIGHT, 120, LINE_HEIGHT) unless @crs.admision.nil?
        
        add_label("Hizo la Fidelidad", 255, @pdf.cursor+LINE_HEIGHT,80,LINE_HEIGHT)
        add_field("#{@crs.fidelidad.strftime("%d-%m-%Y")}" ,335 , @pdf.cursor+LINE_HEIGHT, 188, LINE_HEIGHT) unless @crs.fidelidad.nil?

        @pdf.start_new_page
        @pdf.move_down LINE_HEIGHT

        add_label("Ha manifestado su disposición de ser sacerdote", 0, @pdf.cursor+LINE_HEIGHT,235,LINE_HEIGHT)
        add_field("#{@crs.letter.strftime("%d-%m-%Y")}" ,235 , @pdf.cursor+LINE_HEIGHT, 100, LINE_HEIGHT) unless @crs.letter.nil?
        
        add_label("Hizo la Admissio", 335, @pdf.cursor+LINE_HEIGHT,100,LINE_HEIGHT)
        add_field("#{@crs.admissio.strftime("%d-%m-%Y")}" ,435 , @pdf.cursor+LINE_HEIGHT, 85, LINE_HEIGHT) unless @crs.admissio.nil?
        @pdf.move_down LINE_HEIGHT


        add_label("Recibió el Lectorado", 0, @pdf.cursor+LINE_HEIGHT,235,LINE_HEIGHT)
        add_field("#{@crs.lectorado.strftime("%d-%m-%Y")}" ,235 , @pdf.cursor+LINE_HEIGHT, 100, LINE_HEIGHT) unless @crs.lectorado.nil?
        
        add_label("Recibió el Acolitado", 335, @pdf.cursor+LINE_HEIGHT,100,LINE_HEIGHT)
        add_field("#{@crs.acolitado.strftime("%d-%m-%Y")}" ,435 , @pdf.cursor+LINE_HEIGHT, 85, LINE_HEIGHT) unless @crs.acolitado.nil?
        @pdf.move_down LINE_HEIGHT

        add_label("Ordenado Diácono", 0, @pdf.cursor+LINE_HEIGHT,235,LINE_HEIGHT)
        add_field("#{@crs.diaconado.strftime("%d-%m-%Y")}" ,235 , @pdf.cursor+LINE_HEIGHT, 100, LINE_HEIGHT) unless @crs.diaconado.nil?
        
        add_label("Ordenado Sacerdote", 335, @pdf.cursor+LINE_HEIGHT,100,LINE_HEIGHT)
        add_field("#{@crs.presbiterado.strftime("%d-%m-%Y")}" ,435 , @pdf.cursor+LINE_HEIGHT, 85, LINE_HEIGHT) unless @crs.presbiterado.nil?
        @pdf.move_down LINE_HEIGHT

        add_label("Datos y Circunstacias Familiares", 0, @pdf.cursor+LINE_HEIGHT,235,LINE_HEIGHT)
        @pdf.move_down LINE_HEIGHT
        add_field("Padres: #{@personal.father_name} y #{@personal.mother_name}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT) unless @personal.father_name.nil?
        @pdf.move_down LINE_HEIGHT
        add_field("Domicilio: #{@personal.parents_address}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT)
        @pdf.move_down LINE_HEIGHT
        add_field("#{@personal.siblings_info}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT)
        @pdf.move_down LINE_HEIGHT
        add_field("#{@personal.parents_info}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT) 
        @pdf.move_down LINE_HEIGHT
        add_field("#{@personal.parents_work}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT) 
        @pdf.move_down LINE_HEIGHT
        add_field("#{@personal.economic_info}" ,60 , @pdf.cursor+LINE_HEIGHT, 460, LINE_HEIGHT)
        
        @pdf.move_down LINE_HEIGHT
        
        add_label("Antecedentes Médicos", 0, @pdf.cursor+LINE_HEIGHT,140,LINE_HEIGHT)    
        add_field("#{@personal.medical_info}" ,140 , @pdf.cursor+1.5*LINE_HEIGHT, 385, 1.5*LINE_HEIGHT)
        @pdf.move_down LINE_HEIGHT
        
        add_label("Observaciones", 0, @pdf.cursor+LINE_HEIGHT,140,1.5*LINE_HEIGHT)    
        add_field("#{@personal.notes}" ,140 , @pdf.cursor+1.5*LINE_HEIGHT, 385, 1.5*LINE_HEIGHT)
        
        @pdf.move_down 1.5*LINE_HEIGHT
        
        @pdf.font('Times-Roman', size: 8)
        @pdf.text "C 38", align: :left

    end



    def add_paragraph(text)
        @pdf.text text, indent_paragraphs: 20, align: :justify  
        @pdf.move_down 10
    end

    def add_document_date(date)
        @pdf.move_down 20
        @pdf.text "Roma, #{latin_date(date)}", indent_paragraphs: 20, align: :right  
        #@pdf.bounding_box([-85, -80], :width => 20, height:20) do 
        #    @pdf.font('Palatino', size: 8)
        #    @pdf.text text
        #end
    end

    def latin_date(date)
        date_array = date.split("-")
        "#{date_array[2]} #{MONTHS_LATIN[date_array[1].to_i-1]} #{date_array[0]}"
    end


    def add_document_number(text)
        @pdf.bounding_box([-85, -80], :width => 20, height:20) do 
            @pdf.font('Palatino', size: 8)
            @pdf.text text
        end
    end

    def add_title(settings)
        @pdf.bounding_box([20, @pdf.cursor], :width => @pdf.bounds.width-settings[:indent], height:settings[:height]) do 
            #@pdf.stroke_bounds
            #@pdf.font('Palatino', size: 16)
            @pdf.text settings[:title], align: :center  
        end
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
            @pdf.text text, valign: :bottom, :style => :bold, align: :left
        end
    end


end
 