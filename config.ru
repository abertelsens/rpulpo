require './app/main.rb'

# Sinatra (optional) config
enable :logging, :static

configure :production do
  disable :logging
end

run Sinatra::Application