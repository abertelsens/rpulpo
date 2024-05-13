
puts Rainbow("PULPO: loading puma configuration file").yellow

name = "rpulpo"
port 2948

if ARGV.include? "production"
    environment "production"
else
    environment "development"
end

RUN="/var/www/run/"


preload_app!
