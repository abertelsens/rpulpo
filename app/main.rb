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
require 'commonmarker'
require 'github/markup'
require_rel 'models'
require_rel 'routes'

include ActiveRecord
include ExcelRoomImporter

include ExcelImporter

#---------------------------------------------------------------------------------------
# DB SETUP
#---------------------------------------------------------------------------------------
puts Rainbow("PULPO: Starting Configuration").yellow


# do not print to console
old_logger = ActiveRecord::Base.logger
#ActiveRecord::Base.logger = nil

# To turn active record logger back on
ActiveRecord::Base.logger = old_logger

DB_ENV ||= 'development'

#load the connection settings fie and open the connection

connection_details = YAML::load(File.open('config/database.yaml'))
ActiveRecord::Base.establish_connection(connection_details[DB_ENV])
ADMIN_USER = User.find_by(uname: "ale")

#---------------------------------------------------------------------------------------
# SINATRA SETUP
#---------------------------------------------------------------------------------------

#enables sessions to allow access control
enable :sessions

set :public_folder, 'public'

#0 do not print anything, 1 print controller info, 2 print params
SINATRA_LOG_LEVEL = 2

#---------------------------------------------------------------------------------------
# SLIM SETUP
#---------------------------------------------------------------------------------------

Slim::Engine.disable_option_validator!
Slim::Engine.set_options shortcut: {'&' => {tag: 'input', attr: 'type'}, '#' => {attr: 'id'}, '.' => {attr: 'class'}}
set :partial_template_engine, :slim

#---------------------------------------------------------------------------------------
# LOGIN ROUTES
#---------------------------------------------------------------------------------------

# actons performed before any route.
before '/*' do
    print_controller_log
end

# renders the main page
get '/' do
    @current_user = get_current_user
    @current_user ? (slim :home) : (redirect '/login')
end

# renders the login page
get '/login' do
    @auth_error=true if params[:auth_error]=="true"
    slim :login, layout: false
    #partial :"login"
end

# renders the navigation bar
get '/navbar' do
    @current_user = get_current_user
    partial :navbar
end

# reset the current user cookie and redirect to login page
get '/logout' do
    cookies[:current_user_id] = nil
    redirect '/login'
end

post '/login' do
    @user = User.authenticate(params[:uname],params[:password])
    @auth_error = @user==false
    if @user
        cookies[:current_user_id] = @user.id    #sets the current_user_id in the cookies
        redirect '/'
    else
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
