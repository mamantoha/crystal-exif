require "../src/exif"

file = File.open("#{__DIR__}/../spec/fixtures/metadata_test.jpg")
path = file.path

exif = Exif.new(path)
p! exif.mnote_data
