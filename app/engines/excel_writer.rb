require 'yaml'
require 'rubyXL'

class ExcelWriter  < DocumentWriter

EXCEL_TEMPLATES_DIR ="app/engines-templates/excel"

    def initialize(document, people)
        @document = document
	    @people = people
        @workbook = RubyXL::Workbook.new    #   creates the workbook
        @status = true
        @document_path = "#{EXCEL_TEMPLATES_DIR}/#{@document.path}"
        if !File.file? @document_path
            set_error(FATAL,"ExcelWriter: Template #{@document.path} not foud in #{EXCEL_TEMPLATES_DIR}. You should check the settings of #{@document.name} file before trying again.")
            return
        else
            write_excel if (parse_yaml @document_path)
        end
    end

    def parse_yaml(file_path)    
        
        yaml = YAML.load_file(file_path)
        if yaml.empty? 
            set_error(FATAL,"ExcelWriter: Template #{@document.path} is not well formed. You should check the file before trying again.")
            return false
        end
        
        yaml_worksheets = yaml["worksheets"]
        if yaml_worksheets.nil?
            set_error(FATAL,"ExcelWriter: Template #{@document.path} is not well formed. Cannot find the worksheet(s) definition. You should check the file before trying again.")
            return false
        end
        
        begin 
            @worksheets_names = yaml_worksheets.map {|worksheet| worksheet["name"]}
            @worksheets_settings = []
            yaml["worksheets"].each_with_index do |worksheet, index|
                @worksheets_settings[index] = worksheet["fields"].map {|field| {id: field["value"], column_name: field["name"]}}
            end
        rescue => error
            # as the error is not fatal we keep going
            set_error(WARNING, "Excel Writer: failed to write document headers: #{error.message}")
        end
        return true
    end

    def write_excel
        begin
            @workbook.worksheets.delete @workbook[0]					# deletes the first worksheet which is created automatically.
            @worksheets_names.each {|wn| @workbook.add_worksheet wn }   # adds all the worksheets
            @worksheets_settings.each_with_index do |ws,index|
                write_headers(@workbook[index], ws.map{ |field| field[:column_name] })
                write_data(@workbook[index], ws.map{ |field| field[:id]} , @people)
            end
            @output = @workbook.write("tmp/#{@document.name}.xlsx")
        rescue => error
            set_error(FATAL, "Excel Writer: failed to write document values: #{error.message}")
        end
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
        @output
    end

end #class end
