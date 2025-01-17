
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
require 'sinatra/prawn'
require_relative 'sinatra_helpers'  # helpers for the sinatra controllers
require 'require_all'
#require_rel 'sinatra/htmlescape'

# include all the models defined in the 'app/models' directory
require_rel 'models'
require_rel 'utils'

#C:\Ruby32-x64\bin

# include all the routes defined in the 'app/routes' directory
require_rel 'routes'
require_rel 'decorators'

# modules
include ActiveRecord
include Utils

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
	@allowed_modules = @current_user.get_allowed_modules.pluck(:identifier)
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

post '/login/check_credentials' do
	@user = User.authenticate params[:uname], params[:password]
	result = @user!=false
	cookies[:current_user_id] = @user.id if result    #sets the current_user_id in the cookies
	return {result: result}.to_json
end


# make sure there is at least one admin user.
User.ensure_admin_user	#make sure there is at least one admin user.
# Credentials of the first admin user.

puts Rainbow("PULPO: admin #{User.admin[0].to_s}").yellow

# make sure all people have a picture.
Person.all.each do |person|
	has_photo = (File.exist?("app/public/photos/#{person.id}.jpg"))
	puts "#{person.short_name} did not have a photo" unless has_photo
	FileUtils.cp_r("app/public/img/avatar.jpg", "app/public/photos/#{person.id}.jpg", remove_destination: false) unless has_photo
end



	# Document.all.each {|doc| doc.update(engine: "typst") if doc.engine==nil}
=begin
	Person.all.each {|person| person.update({"guest"=> person.ctr=="guest"})}
	Person.all.each do |person|
		puts person.birth
		person.update("celebration"=> person.birth)
	end
	Person.all.each {|person| person.update("dinning_room"=> (person.group=="1" || person.group=="2" ? "abajo" : "arriba")) }
	=end

	# Start the thread when the application starts
	#Person.all.each do |person|
	#	puts person.birth
	#	person.update("celebration"=> person.birth)
	#end
=end

	#Person.start_update_celebration_thread
	
	decorator = ARDecorator.new(Person.first, :default_date, :clean_strings)
	decorate_boolean 	= proc { |value| value ? "\u2714".encode('utf-8') : "" }
	is_boolean 				= proc { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) } 

	is_date						= proc {|date| date.is_a?(Date)}
	decorate_date = proc do |date| 
		formatted_date = date.strftime("%d-%m-%y")
		puts "Formatting date: #{date} -> #{formatted_date}"
		formatted_date
	end

	#decorator.register is_date, decorate_date
	#decorator.register is_boolean, decorate_boolean

	decorate_name = proc { |person| "#{person.first_name} #{person.family_name}"}
	#puts decorator.get_value(decorate_boolean, :student)
	#puts decorator.get_attribute("student")
	#puts decorator.get_attribute(:student)
	puts decorator.get_attribute(decorate_name)
	#puts decorator.get_attribute(:birth)

	#puts decorator.get_attribute([:birth, :first_name, :family_name])

	#puts "checking if date" 
	#p is_date.call(Person.first[:birth])
	#puts decorator.get_attribute("crs_records.oblacion")
	#puts decorator.get_attribute("crs_recordggg.oblacion")
	puts decorator.get_csv %w(first_name family_name birth)
