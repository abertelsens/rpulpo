require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

FONT_NAME = 'Helvetica'     
FONT_SIZE = 11     
HEADER_COLOR= 'e6f2ff'
HEADER_BORDER= 'thin'
WORKSHEET_DATA_NAME = "pulpo-data"

class ExcelDocument

    def initialize(path, data)
        @template = RubyXL::Parser.parse(path)
        @template_worksheet = @template[0]
        @template_headers = read_template_headers @template_worksheet

        @data_worksheet =  @template[1].nil? ? @template.add_worksheet(WORKSHEET_DATA_NAME) : @template[1]
        export @data_worksheet, data
        @template.write path
    end

    def read_template_headers worksheet
        return worksheet[0].cells.map {|cell| cell.nil? ? '' : cell.value }
    end

    def render
        return @template_headers.to_s
    end

    def export(worksheet, people)
        @template_headers.each_with_index do |header, col_index|  
            worksheet.add_cell(0, col_index, header)
        end
        
        people.each_with_index do |person, row_index|
            @template_headers.each_with_index do |header, col_index|    
                worksheet.add_cell(row_index+1, col_index, person.get_attribute(header))
            end
        end
    end

    def get_variable_value(var,person)
        # clean the $ characters and parse the variable.
        variable_identifier = var.gsub("$","")
        variable_array = variable_identifier.split(".")
            return person.get_attribute(variable_identifier)
    end

end

