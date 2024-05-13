#require 'os'
require 'rainbow'
require 'sinatra'
require 'sinatra/cookies'
require "sinatra/activerecord"
require 'slim/include'
require 'sinatra/partial'
require 'sinatra/reloader'
require_relative 'sinatra_helpers'  #helpers for the sinatra controllers
require 'require_all'
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

# if the DB ENVIRONMENT is not set (i.e. was not set via the command line to run the app)
# we assume we are in development mode.
DB_ENV ||= 'development'

#load the connection settings file and open the connection
connection_details = YAML::load(File.open('config/database.yaml'))
ActiveRecord::Base.establish_connection(connection_details[DB_ENV])

#---------------------------------------------------------------------------------------
# SINATRA SETUP
#---------------------------------------------------------------------------------------

#enables sessions to allow access control
enable :sessions

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

# actons performed before any route is run.
before '/*' do
	print_controller_log
end

# renders the main page
get '/' do
	@current_user = get_current_user
	@current_user ? (slim :home) : (redirect '/login')
end

# renders the login page. If the auth_error parameter is set, it meams there was an
# authentication error.
get '/login' do
	@auth_error = params[:auth_error]=="true"
	slim :login, layout: false
end

# reset the current user cookie and redirect to login page
get '/logout' do
	cookies[:current_user_id] = nil
	redirect '/login'
end

post '/login' do
	@user = User.authenticate params[:uname], params[:password]
	@auth_error = @user==false
	if @user
		cookies[:current_user_id] = @user.id    #sets the current_user_id in the cookies
		redirect '/'
	else
		redirect '/login?auth_error=true'
	end
end
