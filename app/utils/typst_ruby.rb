
# typst_ruby.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2025-01-10
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A wrapper class to produce pdf documents via Typst. The class relies on the typst
# compiler. See https://github.com/typst/typst

#---------------------------------------------------------------------------------------

require 'os'
require 'tmpdir'

TYPST_CMD = "typst"

class TypstRuby

  def self.assert?
    return system("where #{TYPST_CMD}") if OS.windows?
    return system("which #{TYPST_CMD}") if OS.posix?
  end

  def initialize(file_path=nil)
    if !TypstRuby.assert?
      puts "Typst compiler not found in the system. Please install it and try again."
      return nil
    end
    @src_path = file_path unless file_path.nil?
  end

  def compile(data=nil)
    puts "Typst Ruby: compiling document..."
    p data

    Dir.mktmpdir do |d|
      # write the input file
      File.open("#{d}/input.typ", 'w') { |f| f.write data }

      begin
        res = system("#{TYPST_CMD} compile #{d}/input.typ #{d}/oupput.pdf")
        res ? ("#{d}/oupput.pdf") : nil

      rescue => error
        puts "Typst Ruby: failed to convert document: #{error.message}"
        return nil
      end

    end

  end

end #class end
