# Rakefile
require_relative 'app/main'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

namespace :db do

  task :create do
    ActiveRecord::Base.establish_connection(settings.database)
    ActiveRecord::Base.connection.create_database(settings.database[:database])
  end

  task :migrate do
      Rake::Task['db:migrate'].invoke
  end

end
