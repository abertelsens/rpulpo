require 'yaml'

class ExcelWriter

EXCEL_TEMPLATES_DIR ="app/engines-templates/excel"

    def initialize(document, people)
        @document = document
	    @people = people
        @workbook = RubyXL::Workbook.new    #   creates the workbook
        parse_yaml "#{EXCEL_TEMPLATES_DIR}/#{@document.path}"
        write_excel
    end

    def parse_yaml(file_path)    
        yaml = YAML.load_file(file_path)
        @worksheets_names = yaml["worksheets"].map {|worksheet| worksheet["name"]}
        @worksheets_settings = []
        yaml["worksheets"].each_with_index do |worksheet, index|
            @worksheets_settings[index] = worksheet["fields"].map {|field| {id: field["value"], column_name: field["name"]}}
        end
    end

    def write_excel
        @workbook.worksheets.delete @workbook[0]					# deletes the first worksheet which is created automatically.
        @worksheets_names.each {|wn| @workbook.add_worksheet wn }   # adds all the worksheets
        @worksheets_settings.each_with_index do |ws,index|
					write_headers(@workbook[index], ws.map{ |field| field[:column_name] })
					write_data(@workbook[index], ws.map{ |field| field[:id]} , @people)
        end
        @output = @workbook.write("tmp/#{@document.name}.xlsx")
    end

    def write_headers(ws, header_names)    
        header_names.each_with_index { |h,index| ws.add_cell(0,index,h)}
    end

    def write_data(workseet, ws_attributes, people)
        people.each_with_index do |person,row_index|    
            ws_attributes.each_with_index {|att, col_index| workseet.add_cell(row_index+1,col_index,person.get_attribute(att)) }
        end    
    end

    def render()
        return @output
    end

end #class end
