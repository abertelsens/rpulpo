
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
require 'fileutils'

TYPST_CMD = "typst"
TYPST_ROOT = "app/public"
TYPST_TMP_DIR = "app/public/tmp/typst"

FileUtils.mkdir_p TYPST_TMP_DIR


class TypstRuby

  def self.assert?
    return system("where #{TYPST_CMD}") if OS.windows?
    return system("which #{TYPST_CMD}") if OS.posix?
  end

  def initialize(file_path=nil)
    puts "Initializing TypstRuby"
    if !TypstRuby.assert?
      puts "Typst compiler not found in the system. Please install it and try again."
      return nil
    end

    @src_path = file_path unless file_path.nil?
  end

  # Compiles the given data using Typst compiler.
  # @param data [String] the data to compile
  # @return [String, nil] the path to the compiled PDF file or nil if compilation failed
  def compile(data=nil)

    clean_tmp_files

    random = rand(10000).to_s
    input_file =  "#{TYPST_TMP_DIR}/#{random}.typ"
    output_file = "#{TYPST_TMP_DIR}/#{random}.pdf"

    File.open(input_file, 'w') { |f| f.write data }

    puts "compiling #{TYPST_CMD} compile --root #{TYPST_ROOT} #{input_file} #{output_file}"
    begin
      res = system "#{TYPST_CMD} compile --root #{TYPST_ROOT} #{input_file} #{output_file}"
      puts "res #{res}"
      res ? output_file : nil
    rescue => error
      puts "Typst Ruby: failed to convert document: #{error.message}"
      return nil
    end
  end

  # Cleans up temporary files older than one day.
  def clean_tmp_files
    Dir.glob("#{TYPST_TMP_DIR}/*").each do |file|
      File.delete(file) if (Time.now - File.mtime(file)) > 86400 # 86400 seconds in a day
    end
  end


end #class end
