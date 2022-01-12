require 'tempfile'

file = Tempfile.new('foo.yml')

puts file.path
