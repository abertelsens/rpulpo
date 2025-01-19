# room.rb
#---------------------------------------------------------------------------------------
# FILE INFO
#
# author: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION
#
# A class for interacting with Google Sheets using the Google Sheets API.
# This class provides methods to authenticate, update, and clear values in Google Sheets.
#---------------------------------------------------------------------------------------

require 'google-apis-sheets_v4'
require 'googleauth'

class GSheets

  # initial setup. Uncomment to get a more complete log from the gsheets API
   Google::Apis.logger = Logger.new(STDOUT)
   Google::Apis.logger.level = Logger::DEBUG

  # Set up authentication (use your service account JSON or API key)
  KEY_FILE  = 'config/pulpo-414809-6761bd26adf2.json' # Replace with the path to your JSON key file
  SCOPES    = ['https://www.googleapis.com/auth/spreadsheets']
  SHEETS    =
  {
    rooms_by_clothes: {
      sheet_id: '11-ymy2jf2_w_t4iwoQLvy0JBsX6EYPQ4kTlc25A1ffE',
      sheet_name: 'pulpo_test',
      headers: false,
      x_offset: 2,
      y_offset: 6
    },
    rooms_by_house: {
      sheet_id: '11-ymy2jf2_w_t4iwoQLvy0JBsX6EYPQ4kTlc25A1ffE',
      sheet_name: 'pulpo_test',
      headers: false,
      x_offset: 9,
      y_offset: 6
    },
    celebrations: {
      sheet_id: '11-ymy2jf2_w_t4iwoQLvy0JBsX6EYPQ4kTlc25A1ffE',
      sheet_name: 'pulpo_test2',
      headers: false,
      x_offset: 3,
      y_offset: 5
    }
  }

  # Create authorization credentials
  authorization = Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io:  File.open(KEY_FILE),
    scope:        SCOPES
  )

  # Initialize the Sheets API service
  @@sheets_service = Google::Apis::SheetsV4::SheetsService.new
  @@sheets_service.authorization = authorization

  # Initialize a new GSheets object
  # @param spreadsheet [Symbol] the key for the spreadsheet configuration in SHEETS
  def initialize(spreadsheet)
    @sheet = SHEETS[spreadsheet]
    @spreadsheet_id = SHEETS[spreadsheet][:sheet_id]
    @sheet_name = SHEETS[spreadsheet][:sheet_name]
  end

  # Update the Google Sheet with the provided data
  # @param settings [Object] the settings for the table
  # @param collection [Array] the collection of objects to be written to the sheet
  # @param decorator [Object] the decorator to format the objects
  def update_sheet(values)
    range = calculate_range(values)
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: values)
    # Update the cells
    begin
      result = @@sheets_service.update_spreadsheet_value(
        @sheet[:sheet_id],
        range,
        value_range,
        value_input_option: 'RAW' # Options: 'RAW' (exact) or 'USER_ENTERED' (processed)
      )
      puts value_range
      puts "Successfully updated cell #{range}: #{result.updated_cells} cell(s) updated."

      # Clear rows below the updated values
      start_column_letter, start_row = range.split(':').first.match(/([A-Z]+)(\d+)/).captures
      end_column_letter = range.split(':').last.match(/([A-Z]+)/).captures.first
      clear_range = "#{@sheet_name}!#{start_column_letter}#{start_row.to_i + values.length}:#{end_column_letter}"
      @@sheets_service.clear_values(@sheet[:sheet_id], clear_range)
      puts "Cleared rows below the updated values in range: #{clear_range}"
    rescue Google::Apis::ClientError => e
      puts "An error occurred: #{e.message}"
    end
  end

  private

=begin
  # Prepare the values to be written to the Google Sheet
  # @param settings [Object] the settings for the table
  # @param collection [Array] the collection of objects to be written to the sheet
  # @param decorator [Object] the decorator to format the objects
  # @return [Array] the prepared values
  def prepare_values(attributes, collection)
    # get the headers names
    headers = settings.att.map { |att| att.name.humanize(capitalize: false) }
    decorator = ARDecorator.new(collection)
    values = collection.map { |object| decorator.to_array(object) }
    @sheet[:headers] ? [headers] + values : values
  end
=end

  def calculate_range(array)
    # Get the dimensions of the array
    start_row = @sheet[:y_offset]
    start_column = @sheet[:x_offset]
    num_rows = array.length
    num_cols = array[0].length

    # Calculate the range
    end_row     = start_row + num_rows - 1
    end_column  = start_column + num_cols - 1

    # Convert columns from numeric index to letter (A, B, C, ...)
    start_col_letter = ('A'.ord + start_column - 1).chr
    end_col_letter = ('A'.ord + end_column - 1).chr

    # Construct the range string
    "#{@sheet[:sheet_name]}!#{start_col_letter}#{start_row}:#{end_col_letter}#{end_row}"
  end

end #class end
