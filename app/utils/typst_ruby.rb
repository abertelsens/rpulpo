
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
    if !data.nil?
      src_file = (Tempfile.new [ 'typst_input', '.typ' ])
      File.open(src_file.path, 'w') {|f| f.write data }
      @src_path = src_file.path
    end
    begin
      out_file = Tempfile.new [ 'typst_output', '.pdf' ]
      res = system("#{TYPST_CMD} compile #{@src_path} #{out_file.path}")
      res ? (out_file) : nil
    rescue => error
      puts "Typst Ruby: failed to convert document: #{error.message}"
      return nil
    end
  end

end #class end
