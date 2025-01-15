require 'sinatra/base'

module Sinatra
  module Typst
    module Helpers

      def typst(template=nil, options={}, locals = {}, &block)
        render :typst, template, options, locals
      end
    end

    def self.registered(app)
      # register the helper in sinatra
      app.helpers Typst::Helpers
    end
  end

  register Typst
end


module Tilt

  class TypstTemplate < Template

    def evaluate(scope, locals, &block)
      puts "scope #{scope}"
      puts "locals #{locals}"

      typst_writer = TypstWriter.new (Document.find(locals[:doc_id]))
      data = typst_writer.write locals
      puts "got data #{data}"
      output = Tilt::ERBTemplate.new{data}.evaluate scope, locals
      puts "got ooutput #{output}"
      TypstRuby.new.compile(output)
    end

  end

  register 'typst', TypstTemplate

end
