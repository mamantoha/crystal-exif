require "../src/exif"

path = ARGV[0]?

abort "Error: File required" unless path
abort "Error: File not found - #{path}" unless File.exists?(path)

file = File.open(path)
exif = Exif.new(file)

data = exif.data

data = data.transform_keys(&.camelcase)

len = data.keys.max_of(&.size)

data.each do |key, value|
  puts "#{key.ljust(len)} : #{value}"
end

