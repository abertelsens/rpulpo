require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

EXPORT_FILE = "tmp/export_datos_alumnos.xlsx"
FONT_NAME = 'Helvetica'     
FONT_SIZE = 11     
HEADER_COLOR= 'e6f2ff'
HEADER_BORDER= 'thin'

class Excelexport

    def initialize(people)
        @workbook = RubyXL::Workbook.new
        @worksheet = @workbook[0]
        export people
        @workbook.write(EXPORT_FILE)
        File.new(EXPORT_FILE, "r").close
    end

    def export(people)
        write_headers
        write_rows people
    end

    def write_headers
        headers = Person.get_attributes.map{|att| att[:name]}
        headers.each_with_index do |header,index|
            @worksheet.add_cell(0, index, header)
        end
        
        @worksheet.change_row_bold(0,true)   #make the headers bold
        @worksheet.change_row_font_name(0, FONT_NAME)
        @worksheet.change_row_border(0, :bottom, HEADER_BORDER)
        @worksheet.change_row_fill(0, HEADER_COLOR)            # Sets first row to have fill #0ba53d
        @worksheet.change_row_font_size(0, FONT_SIZE)   
    end    

    def write_rows people
        people.each_with_index do |person,index|
            write_row person, index+1
            @worksheet.change_row_font_name(index+1, FONT_NAME)  
            @worksheet.change_row_font_size(index+1, FONT_SIZE)      
        end

    end
    
    def write_row(person,row)
        Person.get_attributes.each_with_index do |att,index|
            if att[:value]=="att"
                cell = @worksheet.add_cell(row, index, person[att[:att_symb]])
            else
                cell = @worksheet.add_cell(row, index, person.send("get_#{att[:att_symb].to_s}"))
                cell.set_number_format('m/d/Y') if att[:format]=="date"
            end
        end
    end  

    def get_workbook
        @workbook
    end

    def get_file_path
        EXPORT_FILE
    end


end
