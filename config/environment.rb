ENV['SINATRA_ENV'] ||= "development"
ENV['RACK_ENV'] ||= "development"
#ENV['SINATRA_OBJECTS'] ||= "./app/settings/sinatra_objects.yml"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])

puts "running environment.rb"

# Sinatra "sets" the database with the corresponding adapter.
# If there is an enviroment variable set with the databse URL (like in heroku) it will be used
# if not then it means we are running locally
#set :database, {adapter: "postgresql", database: ENV['DATABASE_URL'] || LOCAL_DB_PATH}


