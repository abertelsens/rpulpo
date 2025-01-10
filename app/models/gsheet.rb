require 'google-apis-sheets_v4'
require 'googleauth'

class GSheets

  # initial setup
  Google::Apis.logger = Logger.new(STDOUT)
  Google::Apis.logger.level = Logger::DEBUG

  # Set up authentication (use your service account JSON or API key)
  key_file = 'config/pulpo-414809-6761bd26adf2.json' # Replace with the path to your JSON key file
  scopes = ['https://www.googleapis.com/auth/spreadsheets']

  authorization = Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io: File.open(key_file),
    scope: scopes
  )
  # Initialize the Sheets API service
  @@sheets_service = Google::Apis::SheetsV4::SheetsService.new
  @@sheets_service.authorization = authorization

  def initialize(spreadsheet_id, sheet_name)
    @spreadsheet_id = '11-ymy2jf2_w_t4iwoQLvy0JBsX6EYPQ4kTlc25A1ffE' # Replace with your actual Spreadsheet ID
    @sheet_name = sheet_name
  end

  def rooms2Array
    rooms = Room.in_use_sorted_by_person_clothes.map{|room| [room.person.clothes, room.house, room.room, room.person&.status] }
    rooms
  end

  def update_rooms()
    rooms = rooms2Array
    size = rooms.size

    update_columns(rooms[0..(size/3).floor-1], 6, 2)
    puts "from #{0} to #{(size/3).floor-1}"
    update_columns(rooms[((size/3).floor)..((size/3).floor)*2-1], 6, 7)
    puts "from #{((size/3).floor)} to #{((size/3).floor)*2-1}"
    update_columns(rooms[(((size/3).floor)*2)..size], 6, 12)
    puts "from #{(((size/3).floor)*2)} to #{size}"

    range = calculate_range(rooms, 5, 2)

  end

  def update_columns(data,start_row,start_column)
    range = calculate_range(data, start_row, start_column)
    # Set up the values for updating
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: data)

    # Update the cell
    begin
      result = @@sheets_service.update_spreadsheet_value(
        @spreadsheet_id,
        range,
        value_range,
        value_input_option: 'RAW' # Options: 'RAW' (exact) or 'USER_ENTERED' (processed)
      )
      puts "Successfully updated cell #{range}: #{result.updated_cells} cell(s) updated."
    rescue Google::Apis::ClientError => e
      puts "An error occurred: #{e.message}"
    end
  end

  def calculate_range(array, start_row=1, start_column=1)


    # Get the dimensions of the array
    num_rows = array.length
    num_cols = array[0].length

    # Calculate the range
    end_row     = start_row + num_rows - 1
    end_column  = start_column + num_cols - 1

    # Convert columns from numeric index to letter (A, B, C, ...)
    start_col_letter = ('A'.ord + start_column - 1).chr
    end_col_letter = ('A'.ord + end_column - 1).chr

    # Construct the range string
    "#{@sheet_name}!#{start_col_letter}#{start_row}:#{end_col_letter}#{end_row}"
  end

end #class end
