
# main.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# This file is the main entry point of the webapp.
# It requires all the necesary files to run the app.
# The main ones are the models that define
# the objects stored in the DB and the route files that tell sinatra how to handle the
# different http requests.
#---------------------------------------------------------------------------------------

require 'rainbow'	# helps to pretty print in the console
require 'sinatra'
require 'sinatra/cookies'
require "sinatra/activerecord"
require 'slim/include'
require 'sinatra/partial'
require 'sinatra/reloader'
require_relative 'sinatra_helpers'  # helpers for the sinatra controllers
require 'require_all'

# include all the models defined in the 'app/models' directory
require_rel 'models'

# include all the routes defined in the 'app/routes' directory
require_rel 'routes'

# modules
include ActiveRecord
include ExcelRoomImporter
include ExcelImporter

#---------------------------------------------------------------------------------------
# DB SETUP
#---------------------------------------------------------------------------------------

puts Rainbow("PULPO: Starting Configuration").yellow

# In order to avoid printing to the console in each request uncomment the following line
# ActiveRecord::Base.logger = nil

# To turn active record logger back on
# old_logger = ActiveRecord::Base.logger
# ActiveRecord::Base.logger = old_logger

# if the DB ENVIRONMENT is not set (i.e. was not set via the command line to run the app)
# we assume we are in development mode.
# The environment variable is set in the puma configuration file puma.rb
ENV["DB_ENV"] ||= 'development'

# load the connection settings file and open the connection
connection_details = YAML::load(File.open('config/database.yaml'))

puts Rainbow("PULPO: Loaded Database connection with environment #{ENV["DB_ENV"]}").yellow
puts Rainbow(connection_details[ENV["DB_ENV"]]).yellow

# establish the connection
ActiveRecord::Base.establish_connection(connection_details[ENV["DB_ENV"]])

#---------------------------------------------------------------------------------------
# SINATRA SETUP
#---------------------------------------------------------------------------------------

# enables sinatra sessions to allow access control for different user sessions
enable :sessions

# I have defined three levels of info displayed in the console for each http request
# 0 do not print anything, 1 print controller info, 2 print params
# the levels in the the 'sinatra_helpers' file.
SINATRA_LOG_LEVEL = 2


#---------------------------------------------------------------------------------------
# SLIM SETUP
#
# Slim is a rendering engine that helps to create html pages via templates with some
# embedded ruby code.
# For more info see https://slim-template.github.io/
#---------------------------------------------------------------------------------------

Slim::Engine.disable_option_validator!

# define some options for slim that help us to write some cleaner templates.
Slim::Engine.set_options shortcut:
	{
		'&' => {tag: 'input', attr: 'type'},
		'#' => {attr: 'id'},
		'.' => {attr: 'class'},
		'@' => {attr: ['id', 'name']},
	}

set :partial_template_engine, :slim

#---------------------------------------------------------------------------------------
# GENERAL ROUTES
#---------------------------------------------------------------------------------------

# We define a method that is called before any route is processed
# In this case we tell sinatra to call the print_controller_log method defined in the 'sinatra_helpers'
# This helps to write shorter and cleaner code for each route
before '/*' do
	print_controller_log
end

# renders the main page
get '/' do
	@current_user = get_current_user
	@current_user ? (slim :layout) : (redirect '/login')
end

get '/elements/navbar' do
	@current_user = get_current_user
	partial :"elements/navbar"
end

#---------------------------------------------------------------------------------------
# LOGIN ROUTES
#---------------------------------------------------------------------------------------

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

# make sure there is at least one admin user.
User.ensure_admin_user	#make sure there is at least one admin user.
# Credentials of the first admin user.

puts Rainbow("PULPO: admin #{User.admin[0].to_s}").yellow
