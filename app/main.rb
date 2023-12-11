require 'os'
require 'rainbow'
require 'sinatra'
require 'sinatra/cookies'
require 'sinatra/flash'
require "sinatra/activerecord"
require 'slim/include'
require 'sinatra/partial'
require 'sinatra/reloader'
require_relative 'sinatra_helpers'  #helpers for the sinatra controllers
require 'require_all'
require_rel 'models'
require_rel 'routes'

include ActiveRecord
#include ExcelRoomImporter

########################################################################################
# DB SETUP
########################################################################################

DB_NAME = 'rpulpo_db'

LOCAL_DB_PATH = "postgres://alejandro@localhost/#{DB_NAME}"

# if running in a remote environment look for the DB URL in the enviroment. If the ENV variable is not
# found then it means we are running locally, so use the LOCAL_DB_PATH
db = URI.parse( ENV['DATABASE_URL'] || LOCAL_DB_PATH)

# do not print to console
old_logger = ActiveRecord::Base.logger
#ActiveRecord::Base.logger = nil

# To turn active record logger back on
ActiveRecord::Base.logger = old_logger

configure :development do
    set :database, {adapter: 'postgresql',  encoding: 'utf8', host: db.host, database: DB_NAME, pool: 2, username: db.user}
end
configure :production do
    set :database, {adapter: 'postgresql',  encoding: 'utf8', host: db.host, database: DB_NAME, pool: 2, username: db.user}
end

########################################################################################
# SINATRA SETUP
########################################################################################

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

ADMIN_USER = User.find_by(uname: "ale")

# actons performed before any route.
before '/*' do
    print_controller_log
end

# renders the main page
get '/' do
    @user = get_current_user()
    @user ? (partial :"home") : (partial :"login")
end

# renders the login page
get '/login' do
    partial :"login"
end

get '/logout' do
    #session[:current_user_id] = nil     #resets the current_user_id cooky
    cookies[:current_user_id] = nil 
    redirect '/'
end

post '/login' do
    puts "POST LOGIN>>>>>"
    @user = User.authenticate(params[:uname],params[:password])
    @auth_error = @user==false
    #set the current session id
    if @user
        puts "got user id #{@user.id}"
        cookies[:current_user_id] = @user.id    #sets the current_user_id in the cookies
        redirect '/'
    else
        partial :"login" if !@user
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
#User.create(uname: "ale",password: "ale", usertype: "admin");
p = Person.find(1)
puts "Atrribute #{p.family_name}"
#Excelimporter::import
#ExcelRoomImporter::import
#pw = Pandoc_Writer.new('app/pandoc/F21.md', Person.all)
#pw.convert

#puts "found variables: #{pw.get_variables()}"

#puts Room.get_empty_rooms