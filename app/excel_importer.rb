require 'rubyXL'

IMPORT_FILE = "tmp/datos_alumnos.xlsx"

module Excelimporter

    def import()
        workbook = RubyXL::Parser.parse IMPORT_FILE
        worksheet = workbook[0]
        
        puts "Reading: #{worksheet.sheet_name}"
        headers = worksheet[0].cells.map(&:value)
        rows = worksheet[1..-1].map do |row|
            row.cells.map { |cell| cell.nil? ? '' : cell.value }
        end
        data = rows.map { |row| Hash[headers.zip(row)] }

    # Print the hash to the console
    puts headers
    #puts data.inspect


    data.each do |row| 
        h_people = {
            first_name: row["Nombre completo"].split(",")[1],
            family_name: row["Nombre completo"].split(",")[0],
            cavabianca:  row["Vive en CB"]=="VERDADERO",
            short_name: row["Nombre completo"].split(",")[1] + " " +row["Nombre completo"].split(",")[0],
            full_name: row["Nombre completo"].split(",")[1] + " " +row["Nombre completo"].split(",")[0],
            nominative: row["Nominativo"],
            accussative: row["Acusativo"],
            lives:    (row["Ha llegado"]=="VERDADERO" ? 1 : 2), #si ha llegado suponemos que está en cb sino en un ctr dependiente
            arrived: row["Ha llegado"]=="VERDADERO",
            teacher: row["Profesor"]=="VERDADERO",
            arrival: row["Llegada"],
            departure: row["salida"],
            birth: row["Fecha de nacimiento"],
            celebration_info: row["Celebra"],
        }
        person = Person.create h_people
        padres = row["Padres"].gsub!("Padres:", "").split(" y ")
        
        h_personal =
        {
            person_id: person.id,
            photo_path: row["foto"],
            region_of_origin: row["Region de origen"],
            region: (row["Region"]=="" ? row["Region de origen"] : row["Region"]==""),
            city: row["Ciudad"],
            languages: row["Idiomas"],
            father_name: padres[0],
            mother_name: padres[1],
            parents_address: row["Domicilio"].gsub!("Domicilio: ",""),
            parents_work: row["Informacion"],
            parents_info: row["Datos"],
            siblings_info: row["Hermanos"],
            economic_info: row["Posicion"],
            medical_info: row["Ant. medicos"],
            notes: row["Observaciones"]
        }
        Personal.create h_personal
        h_studies =
        {
            person_id: person.id,
            civil_studies: row["Estudios civiles"],
            studies_name: row["Carrera"],
            degree: row["Titulo"],
            profesional_experience: row["Otros"],
            year_of_studies: row["Situacion academica"], 
            faculty: row["Facultad"],
            status: row["Estudios institucionales"],
            licence: row["Año licenciatura"],
            doctorate: row["Doctorado"],
            thesis: row["Tesis"]
        }
        Study.create h_studies
        h_crs =
        {
            person_id: person.id,
            classnumber: row["Promocion"],
            pa: row["pa"],
            admision: row["ad"],
            oblacion: row["p"],
            fidelidad: row["fl"],
            letter: row["carta"],
            admissio: row["admissio"],
            presbiterado: row["presbiterado"],	
            diaconado: row["diaconado"],		
            acolitado: row["acolitado"],		
            lectorado: row["lectorado"],			
            cipna: row["cipna"],			
        }
    Crs.create h_crs 
    end
    end

end
#Nominativo	Acusativo	Ha llegado	Vive en CB	Profesor	Llegada	salida	Promoción	Región de origen	Región	Ciudad	Fecha de nacimiento	Situación académica	Estudios civiles	Carrera	Título	pa	ad	o	fl	carta	admissio	presbiterado	diaconado	acolitado	lectorado	cipna	foto	Facultad	Estudios institucionales	Año licenciatura	Doctorado	Tesis	Idiomas	Padres	Domicilio	Hermanos	Datos	Información	Posición	Ant. médicos	Observaciones	Celebra	Actual	Otros	Nombre completo	Nombre breve