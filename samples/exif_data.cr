require "../src/exif"

path = "#{__DIR__}/../spec/fixtures/metadata_test.jpg"
file = File.open(path)

exif = Exif.new(file)

pp exif.data

p! exif.gps_latitude
p! exif.gps_longitude
