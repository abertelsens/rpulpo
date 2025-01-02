require 'sinatra/base'

puts "LOADING FILE"
module Sinatra
  module HTMLEscapeHelper
    def h(text)
      text
    end
  end
  helpers HTMLEscapeHelper
end
