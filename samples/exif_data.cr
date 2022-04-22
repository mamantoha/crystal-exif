require "../src/exif"

file = File.open("#{__DIR__}/../spec/fixtures/metadata_test.jpg")
path = file.path

exif = Exif.new(path)

pp exif.to_h

p! exif.gps_latitude
p! exif.gps_longitude
