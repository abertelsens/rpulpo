require 'localhost'

puts "loading puma configuration file"

name = "rpulpo"
port 2948

ARGV.each do|a|
    puts "Argument: #{a}"
  end
  
if ARGV.include? "production"
    environment "production"
else
    environment "development"
end
RUN="/var/www/run/"

#pidfile "#{RUN}/puma-#{name}.pid"
#bind "unix://#{RUN}/puma-#{name}.sock"
#state_path "#{RUN}/puma-#{name}.state"


preload_app!
