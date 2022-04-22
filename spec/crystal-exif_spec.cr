require "./spec_helper"

describe Exif do
  it "works" do
    file = File.open("#{__DIR__}/fixtures/metadata_test.jpg")
    path = file.path

    exif_data = Exif.new(path)

    hsh = exif_data.to_h
    hsh["make"].should eq("NIKON")
    hsh["model"].should eq("COOLPIX P6000")
    hsh["user_comment"].should eq("")
  end
end
