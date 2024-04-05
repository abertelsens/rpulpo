require 'rubyXL'

IMPORT_FILE = "tmp/rooms.xlsx"
CASAS = {"Dirección" => 0, "Profesores" => 1, "Pabellón" => 2, "Sala de Conferencias"=> 3, "Casa de la Altana" => 4, "Casa de la Chiocciola" => 5, "Casa del Molino" => 6, "Casa del Borgo" => 7, "Ospiti" =>8, "Enfermería" => 9, "Casa del Consejo"=> 10}
module ExcelRoomImporter

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
        h_room = {
            name: row["name"],
            house: CASAS[row["house"]],
            bed: row["bed"],
            phone: row["phone"]
        }
        room = Room.create h_room
    end
end

end
