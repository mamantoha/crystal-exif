require "../src/exif"

file = File.open("#{__DIR__}/../spec/fixtures/metadata_test.jpg")
path = file.path

exif_data = Exif.new(path)

pp exif_data.to_h
