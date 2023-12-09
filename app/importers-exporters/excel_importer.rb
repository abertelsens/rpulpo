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
            first_name: row["nombre completo"].split(",")[1],
            family_name: row["nombre completo"].split(",")[0],
            cavabianca:  row["Vive en CB"]=="VERDADERO",
            short_name: row["nombre completo"].split(",")[1] + " " +row["nombre completo"].split(",")[0],
            full_name: row["nombre completo"].split(",")[1] + " " +row["nombre completo"].split(",")[0],
            nominative: row["nominativo"],
            accussative: row["acusativo"],
            ctr: (row["vive en CB"]==1 ? 0 : 3), #si ha llegado suponemos que está en cb.
            arrival: row["llegada"],
            departure: row["salida"],
            birth: row["nacimiento"],
            celebration_info: row["celebra"],
            status: (row["presbiterado"].blank? ? (row["diaconado"].blank? ? 0 : 1): 2),	
        }
        puts "vive en CB #{row["vive en CB"]}"
        person = Person.create h_people
        padres = row["familia"].gsub!("Padres:", "").split(" y ")
        
        h_personal =
        {
            person_id: person.id,
            photo_path: row["foto"],
            region_of_origin: row["region_origen"],
            region: (row["region"]=="" ? row["region_origen"] : row["region"]==""),
            city: row["ciudad"],
            languages: row["idiomas"],
            father_name: padres[0],
            mother_name: padres[1],
            parents_address: row["domicilio"].gsub!("Domicilio: ",""),
            parents_work: row["info"],
            parents_info: row["datos"],
            siblings_info: row["hermanos"],
            economic_info: row["situacion"],
            medical_info: row["ant_medicos"],
            notes: row["observaciones"]
        }
        Personal.create h_personal
        h_studies =
        {
            person_id: person.id,
            civil_studies: row["estudios civiles"],
            studies_name: row["carrera"],
            degree: row["titulo"],
            profesional_experience: row["otros"],
            year_of_studies: row["situacion academica"], 
            faculty: row["facultad"],
            status: row["estudios institucionales"],
            licence: row["licenciatura"],
            doctorate: row["doctorado"],
            thesis: row["tesis"]
        }
        Study.create h_studies
        h_crs =
        {
            person_id: person.id,
            classnumber: row["promocion"],
            pa: row["pa"],
            admision: row["ad"],
            oblacion: row["o"],
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
