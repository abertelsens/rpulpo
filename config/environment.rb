puts "\nRunning environment.rb\n"

ENV['SINATRA_ENV'] ||= "development"
ENV['RACK_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])

config.active_record.dump_schema_after_migration = true

puts "running environment.rb"

# Sinatra "sets" the database with the corresponding adapter.
# If there is an enviroment variable set with the databse URL (like in heroku) it will be used
# if not then it means we are running locally
# set :database, {adapter: "postgresql", database: ENV['DATABASE_URL'] || LOCAL_DB_PATH}
