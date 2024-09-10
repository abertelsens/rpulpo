
puts "PULPO: loading puma configuration file"

require 'puma/daemon'
#bind 'tcp://0.0.0.0:3000'
workers 2
threads 4
daemonize

name = "rpulpo"
port 2948

if ARGV.include? "production"
    environment "production"
else
    environment "development"
end

RUN="/var/www/run/"


preload_app!
