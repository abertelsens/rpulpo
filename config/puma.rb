
puts "PULPO: loading puma configuration file"

name = "rpulpo"
port 2948

if ARGV.include? "production"
    environment "production"
    ENV["DB_ENV"] = 'production'
else
    environment "development"
    ENV["DB_ENV"] = 'development'
end

RUN="/var/www/run/"


preload_app!
