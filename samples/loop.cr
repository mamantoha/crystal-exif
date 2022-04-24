require "../src/exif"

file = File.open("#{__DIR__}/../spec/fixtures/metadata_test.jpg")
path = file.path

1024.times do |i|
  puts i
  exif = Exif.new(path)
  data = exif.data
  mnote_data = exif.mnote_data

  puts data
  puts mnote_data
end
