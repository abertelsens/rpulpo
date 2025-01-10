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

  def initialize(spreadsheet_id)
    @spreadsheet_id = '11-ymy2jf2_w_t4iwoQLvy0JBsX6EYPQ4kTlc25A1ffE' # Replace with your actual Spreadsheet ID
  end

  def rooms2Array
    rooms = Room.all.map{|room| [room.name, room.person.clothes] }
    rooms
  end


  def calculate_range(sheet_name, array, start_row=1, start_column=1)
    
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
    "#{sheet_name}!#{start_col_letter}#{start_row}:#{end_col_letter}#{end_row}"
  end

  

  puts data

  data = [
    ['Header1', 'Header2', 'Header3'],
    ['Row1 Col1', 'Row1 Col2', 'Row1 Col3'],
    ['Row2 Col1', 'Row2 Col2', 'Row2 Col3']
  ]


  range = calculate_range("pulpo_test",data)

  # Set up the values for updating
  value_range = Google::Apis::SheetsV4::ValueRange.new(values: data)

  # Update the cell
  begin
    result = sheets_service.update_spreadsheet_value(
      spreadsheet_id,
      range,
      value_range,
      value_input_option: 'RAW' # Options: 'RAW' (exact) or 'USER_ENTERED' (processed)
    )
    puts "Successfully updated cell #{range}: #{result.updated_cells} cell(s) updated."
  rescue Google::Apis::ClientError => e
    puts "An error occurred: #{e.message}"
  end
end