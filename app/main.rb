require 'colorize'
require 'sinatra'
require "sinatra/activerecord"
require 'slim/include'
require 'sinatra/partial'
require 'sinatra/reloader' if development?
require 'require_all'
require 'prawn'
require 'prawn/table'
require_relative 'sinatra_helpers'              #helpers for the sinatra controllers
require_rel 'models'
require_relative 'excel_importer'
require_relative 'excel_exporter'
require_relative 'WordDocCreator'
require_relative 'PDFReport'
require_relative 'WordDocCreator'

#include Utils
include ActiveRecord
include Excelimporter

enable :sessions                                #enables sessions to allow access control
DB_NAME = 'rpulpo_db'
LOCAL_DB_PATH = "postgres://ale@localhost/#{DB_NAME}" 
db = URI.parse( ENV['DATABASE_URL'] || LOCAL_DB_PATH)

# do not print to console
old_logger = ActiveRecord::Base.logger
#ActiveRecord::Base.logger = nil

# To turn active record logger back on
ActiveRecord::Base.logger = old_logger

configure :development do
    set :database, {adapter: 'postgresql',  encoding: 'utf8', host: db.host, database: DB_NAME, pool: 2, username: db.user}
end

SINATRA_LOG_LEVEL = 2   #0 do not print anything, 1 print controller info, 2 print params

########################################################################################
# SLIM SETUP
########################################################################################

Slim::Engine.disable_option_validator!
Slim::Engine.set_options shortcut: {'&' => {tag: 'input', attr: 'type'}, '#' => {attr: 'id'}, '.' => {attr: 'class'}}
set :partial_template_engine, :slim


########################################################################################
# LOGIN
########################################################################################

# renders the main page
get '/' do
    print_controller_log
    partial :"home"
end

# renders the people frame after setting the current peopleset
get '/people/frame' do
    print_controller_log
    @peopleset = get_current_peopleset
    partial :"frame/people"
end

########################################################################################
# PERSON
########################################################################################

get '/people/:id/form' do
    print_controller_log
    @person = params[:id]=="new" ? nil : Person.find(params[:id])
    @personal = params[:id]=="new" ? nil : Personal.find_by(person_id: @person.id)
    @study = params[:id]=="new" ? nil : Study.find_by(person_id: @person.id)
    @crs = params[:id]=="new" ? nil : Crs.find_by(person_id: @person.id)
    partial :"form/person"
end

get '/people/:id/view' do
    print_controller_log
    @person = Person.find(params[:id])
    partial :"view/person"
end

# uploads an image
post '/people/:id/image' do
    print_controller_log
    FileUtils.mv(params[:file][:tempfile], "app/public/photos/#{params[:id]}.jpg")
end

post '/people/:id/form' do
    print_controller_log
    @person = (params[:id]=="new" ? nil : Person.find(params[:id]))
    @personal = params[:id]=="new" ? nil : Personal.find_by(person_id: @person.id)
    @study = params[:id]=="new" ? nil : Study.find_by(person_id: @person.id)
    @crs = params[:id]=="new" ? nil : Crs.find_by(person_id: @person.id)
    case params[:commit]
        when "save"     
            if @person.nil? 
                Person.create Person.prepare_params params
            else
                res = @person.update Person.prepare_params params
                check_update_result res
            end
            if @personal.nil? 
                Personal.create Personal.prepare_params params
            else
                res = @personal.update Personal.prepare_params params
                check_update_result res
            end
            if @study.nil? 
                Study.create Study.prepare_params params
            else
                res = @study.update Study.prepare_params params
                check_update_result res
            end
            if @crs.nil? 
                Crs.create Crs.prepare_params params
            else
                res = @crs.update Crs.prepare_params params
                check_update_result res
            end

        when "delete" 
            @person.destroy
            @personal.destroy
            @study.destroy
            @crs.destroy
        when "cancel"
            ""     
    end
    
    puts "redirecting to /people/#{@person.id}/view".yellow
    redirect "/people/frame"
end



########################################################################################
# PEOPLE SETS
########################################################################################

# renders the table of people after updating the current set.
# @objects the people that will be shown in the table
# @peopleset_ids: an array of ids that is used to highlight the people that belong to the set
get '/people/peopleset/:id/table' do
    print_controller_log
    @peopleset = Peopleset.find(params[:id])
    set_current_peopleset @peopleset
    @peopleset_ids = @peopleset.get_people.map {|p| p.id }
    @objects = Person.all.order(full_name: :asc)
    partial :"table/people"
end

# renders the viewer of the set
get '/people/peopleset/:id/view' do
    print_controller_log
    set_current_peopleset = params[:id].to_i
    @peopleset = Peopleset.find(params[:id])
    @people = @peopleset.get_people
    partial :"view/peopleset"
end


# saves the people set, updates the currnet set to the new saved one and reloads all the frame to correctly reflect the changes
post '/people/peopleset/:id/save' do
    print_controller_log
    @peopleset = Peopleset.find(params[:id])
    if params[:commit]=="save" && @peopleset.temporary?
        @peopleset.update(name: params[:name], status:Peopleset::SAVED)     #saves the current set 
        Peopleset.create(status:Peopleset::TEMPORARY)                       #creates a new temporary set to ensure we have one
        session[:current_people_set]=@peopleset.id
    elsif params[:commit]=="save"
        @peopleset.update(name: params[:name], status:Peopleset::SAVED)
    elsif params[:commit]=="delete"
        @peopleset.destroy
        session[:current_people_set]=nil
    end
    redirect "/people/frame"
end

# shows the edit form to save the set
get '/people/peopleset/:id/edit' do
    print_controller_log
    @peopleset = Peopleset.find(params[:id])
    partial :"form/peopleset"
end


########################################################################################
# ACTIONS ON PEOPLE SETS
########################################################################################

# shows the form to edit a field of all the people in the set
get '/people/peopleset/:id/edit_field' do
    @peopleset = Peopleset.find(params[:id])
    partial :"form/set_field"
end

post '/people/peopleset/:id/edit_field' do
    puts "got params #{params}".yellow
    @peopleset = Peopleset.find(params[:id])
    @people = @peopleset.get_people
    @peopleset.edit(params[:att_name], params[params[:att_name]])
    partial :"view/peopleset"
end

# word. 
# TODO
get '/people/current_set/F28' do
    print_controller_log
    content_type 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    @people = get_current_peopleset.get_people()
    puts "Current dir #{Dir.pwd}"
    file = WordDocCreator.F28 ({path: "tmp/F28.docx", people: @people})
    puts "pwd: #{Dir.pwd}"
    puts "filepath: #{file.path}"
    send_file file.path, disposition: 'attachment'#, filename: "F28.docx"
end


# exports the set to excel
get '/people/peopleset/:id/export/excel' do
    print_controller_log
    exporter = Excelexporter.new(Peopleset.find(params[:id]).get_people)
    send_file exporter.get_file_path, :disposition => 'attachment', :type => 'application/excel', :filename => "lista_alumnos.xlsx"
end

# renders the form for the reports that do not need additional info
get '/people/peopleset/:id/report/:report' do
    print_controller_log
    content_type 'application/pdf'
    people = Peopleset.find(params[:id]).get_people
    PDFReport.new(people: people, document_type: params[:report]).render
end

# renders the form for the reports that need some info to be rendered
get '/people/peopleset/:id/report/:report/form' do
    print_controller_log
    @peopleset = Peopleset.find(params[:id])
    @report = params[:report]
    partial :"form/report"
end

# renders a pdf with the params received.
post '/people/peopleset/:id/report/:report/form' do
    print_controller_log
    @peopleset = Peopleset.find(params[:id])
    @people = @peopleset.get_people
    content_type 'application/pdf'
    PDFReport.new(people: @people, date: params[:date], document_type: params[:report]).render
end

# toggles a person from the set.
get '/peopleset/:set_id/toggle/:person_id' do
    print_controller_log
    puts "got current set: #{get_current_peopleset.get_name}".yellow
    @peopleset = Peopleset.find(params[:set_id])
    @peopleset.toggle Person.find(params[:person_id])
    @people = @peopleset.get_people()
    partial :"view/peopleset"
end

# adds or removes all the visible people on a table from the current set.
post '/people/:action' do
    print_controller_log
    @peopleset = get_current_peopleset
    case params[:action]
        when "select" then @peopleset.add_people params[:person_id].keys
        when "clear" then @peopleset.remove_people params[:person_id].keys
    end
    redirect "/people/peopleset/#{@peopleset.id}/view"
end


get '/people/search' do
    @objects = Person.search(params[:q])
    @peopleset = get_current_peopleset
    @peopleset_ids = @peopleset.get_people.map {|p| p.id }
    puts "ids array: #{@peopleset_ids}"
    partial :"table/people"
end


Peopleset.where(status: Peopleset::TEMPORARY).destroy_all
#Person.update_full_info

#Excelimporter::import