require 'rainbow'
require 'mkmf'

EXECUTABLES = %w(pandoc typst)
HR = "---------------------------------------------------------------"

def check_executable(exe_name)
  "checking for #{exe_name}:\t #{find_executable exe_name}"
end

puts HR << "\nChecking dependencies of Pulpo\n" << HR

EXECUTABLES.each{ |exe| check_executable exe }
