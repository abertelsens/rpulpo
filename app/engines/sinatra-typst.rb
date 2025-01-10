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
      typst_writer = TypstWriter.new (Document.find(locals[:doc_id]))
      data = typst_writer.write locals
      output = Tilt::ERBTemplate.new{data}.evaluate scope, locals
      TypstRuby.new.compile(output)
    end

  end

  register 'typst', TypstTemplate

end
