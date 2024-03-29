require 'os'
require 'rainbow'
require 'sinatra'
require 'sinatra/cookies'
require "sinatra/activerecord"
require 'slim/include'
require 'sinatra/partial'
require 'sinatra/reloader'
require_relative 'sinatra_helpers'  #helpers for the sinatra controllers
require 'require_all'
require 'github/markup'
require 'commonmarker'
require_rel 'models'
require_rel 'routes'

include ActiveRecord
include ExcelRoomImporter

include ExcelImporter

########################################################################################
# DB SETUP
########################################################################################

puts Rainbow("PULPO: Starting Configuration").yellow

#DB_NAME = 'rpulpo_db'

#LOCAL_DB_PATH = "postgres://alejandro@localhost/#{DB_NAME}"

# if running in a remote environment look for the DB URL in the enviroment. If the ENV variable is not
# found then it means we are running locally, so use the LOCAL_DB_PATH
#db = URI.parse( ENV['DATABASE_URL'] || LOCAL_DB_PATH)

# do not print to console
old_logger = ActiveRecord::Base.logger
#ActiveRecord::Base.logger = nil

# To turn active record logger back on
ActiveRecord::Base.logger = old_logger

#configure :development do
#    set :database, {adapter: 'postgresql',  encoding: 'utf8', host: db.host, database: DB_NAME, pool: 2, username: db.user}
#end

#configure :production do
#    set :database, {adapter: 'postgresql',  encoding: 'utf8', host: db.host, database: DB_NAME, pool: 2, username: db.user}
#end

########################################################################################
# SINATRA SETUP
########################################################################################
=begin
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require 'localhost'

configure :production do
    set :server, :puma
    set :host, 'ssl://localhost:2948'
    set :force_ssl, true
end
=end

#enables sessions to allow access control
enable :sessions

#0 do not print anything, 1 print controller info, 2 print params
SINATRA_LOG_LEVEL = 2

########################################################################################
# SLIM SETUP
########################################################################################

Slim::Engine.disable_option_validator!
Slim::Engine.set_options shortcut: {'&' => {tag: 'input', attr: 'type'}, '#' => {attr: 'id'}, '.' => {attr: 'class'}}
set :partial_template_engine, :slim

########################################################################################
# LOGIN
########################################################################################
DB_ENV ||= 'development'
connection_details = YAML::load(File.open('config/database.yaml'))
ActiveRecord::Base.establish_connection(connection_details[DB_ENV])

ADMIN_USER = User.find_by(uname: "ale")

# actons performed before any route.
before '/*' do
    print_controller_log
end

# renders the main page
get '/' do
    @current_user = get_current_user
    if @current_user
        puts Rainbow("found user!!!!").yellow
        @current_user = get_current_user()
        slim :home
    else
        puts Rainbow("did not found user!!!!").yellow
       redirect '/login'
    end
end

# renders the login page
get '/login' do
    @auth_error=true if params[:auth_error]=="true"
    slim :login, layout: false
    #partial :"login"
end

# renders the login page
get '/navbar' do
    @current_user = get_current_user
    partial :navbar
end

get '/logout' do
    cookies[:current_user_id] = nil
    redirect '/login'
end

post '/login' do
    @user = User.authenticate(params[:uname],params[:password])
    @auth_error = @user==false
    if @user
        cookies[:current_user_id] = @user.id    #sets the current_user_id in the cookies
        puts Rainbow("login successful").yellow
        redirect '/'
    else
        puts Rainbow("login failed").yellow
        redirect '/login?auth_error=true'
    end
end


# adds or removes all the visible people on a table from the current set.
post '/people/:action' do
    @peopleset = get_current_peopleset
    case params[:action]
        when "select" then @peopleset.add_people params[:person_id].keys
        when "clear" then @peopleset.remove_people params[:person_id].keys
    end
    redirect "/people/peopleset/#{@peopleset.id}/view"
end

# adds or removes all the visible people on a table from the current set.
get '/help' do
    @current_user = get_current_user
    partial :help
end

# adds or removes all the visible people on a table from the current set.
get '/help/:page' do
    file_body = GitHub::Markup.render("{params[:page].md", File.read("app/views/help/#{params[:page]}.md"))
    "<turbo-frame id=\"help_frame\" target=\"help_frame\">
    #{file_body}
    </turbo-frame>"
end



#Person.all.each do |person|
#    person.update(first_name: person.first_name.strip)
#    person.update(family_name: person.family_name.strip)
#    person.update(full_name: "#{person.family_name.strip}, #{person.first_name.strip}")
#end

#User.create(uname: "ale",password: "ale", usertype: "admin");
#p = Person.find(1)
#puts "Atrribute #{p.family_name}"
#ExcelImporter::import
#ExcelRoomImporter::import
#pw = Pandoc_Writer.new('app/pandoc/F21.md', Person.all)
#pw.convert

#puts "found variables: #{pw.get_variables()}"

#puts Room.get_empty_rooms

#Person.all.each do |p|
#    #p.update(ctr:"cavabianca")
#    p.update(vela:"normal")
#end

#Mail.import_from_excel "L:/usuarios/sect/NOTAS/2023/Notas ao 2023.xlsm"
#Mail.import_from_excel "L:/usuarios/sect/NOTAS/2022/Notas ao 2022.xlsm"
#puts "DESTROYING ALL"
#Mail.all.destroy_all
#Mail.import_from_excel_cg "L:/usuarios/sect/CORREO-CG/ARCHIVO/REGISTRO/registro2019.xlsx"
##Mail.import_from_excel_cg "L:/usuarios/sect/CORREO-CG/ARCHIVO/REGISTRO/registro2020.xlsx"
#Mail.import_from_excel_cg "L:/usuarios/sect/CORREO-CG/ARCHIVO/REGISTRO/registro2021.xlsx"
#Mail.import_from_excel_cg "L:/usuarios/sect/CORREO-CG/ARCHIVO/REGISTRO/registro2022.xlsm"
#Mail.import_from_excel_cg "L:/usuarios/sect/CORREO-CG/ARCHIVO/REGISTRO/registro2023.xlsm"
#puts "IMPORTING ALL"
#Mail.import_from_excel_all "L:/usuarios/sect/CORREO-CG/ARCHIVO/REGISTRO/tmp.xlsx"
#Mail.import_from_excel_update_all "L:/usuarios/sect/CORREO-CG/ARCHIVO/REGISTRO/tmp.xlsx"
#User.all.each{|user| user.update(mail:false)}

#SUser.create(id: 1, uname: "sect", password: "sect")

#Mail.all.each do |p|
#p.update(refs_string: p.refs.pluck(:protocol).join(", "))
#p.update(ans_string: p.ans.pluck(:protocol).join(", "))
#end

#£Person.all.each{|person| person.update(student: true)}
#Person.where(status:"sacerdote").each{|person| person.update(student: false)}

#(Crs.where.not(admissio:nil).and(Crs.where(diaconado:nil))).each{|crs| crs.update(phase: "configuracional")}
=begin
type_l = DayType.create(name: "L", description: "laborable: periodo normal de clases" )
DayType.create(name: "D", description: "Domingo y Fiestas A y B sin encargo" )
visitasPM = Task.create(name: "visitas PM")
Task.create(name: "portería T1")
Task.create(name: "portería T2")
Task.create(name: "portería T3")


=end
#Period.create(name: "febrero 2023", s_date: Date::strptime("1-2-2024","%d-%m-%Y"), e_date: Date::strptime("2-2-2024","%d-%m-%Y"))
#type_l = DayType.find_by(name:"L")
#visitasAM = Task.find_by(name: "visitas AM")
#TaskType.create(day_type: type_l, task: visitasAM, s_time: Time.parse("08:00") , e_time: Time.parse("12:30"))
#dt = DateType.create(day_type: type_l, date: Date::strptime("1-2-2024","%d-%m-%Y"))
#dt = DateType.find_by(day_type: type_l, date: Date::strptime("1-2-2024","%d-%m-%Y"))
#
#ta = TaskAssignment.create(person: Person.find_by(clothes: 96), task: visitasAM, date_type: dt )
#ta = TaskAssignment.find_by(person: Person.find_by(clothes: 96), task: visitasAM, date_type: dt)
#ta.get_date_type
#ta.get_task_type

#Document.all.each do |d|
#        d.update(singlepage: false)
#    end
