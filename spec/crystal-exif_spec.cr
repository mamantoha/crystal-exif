require "./spec_helper"

describe Exif do
  file = File.open("#{__DIR__}/fixtures/metadata_test.jpg")
  path = file.path

  it ".to_h" do
    exif = Exif.new(path)

    hsh = exif.to_h

    hsh["compression"].should eq("JPEG compression")
    hsh["image_description"].should eq("")
    hsh["make"].should eq("NIKON")
    hsh["model"].should eq("COOLPIX P6000")
    hsh["user_comment"].should eq("")
    hsh["gps_latitude"].should eq("43, 28, 2.81400000")
    hsh["gps_longitude"].should eq("11, 53, 6.45599999")
  end

  context "instance methods" do
    it ".gps_latitude" do
      exif = Exif.new(path)

      exif.model.should eq("COOLPIX P6000")
    end

    it ".gps_latitude" do
      exif = Exif.new(path)

      exif.gps_latitude.should eq("43, 28, 2.81400000")
    end
  end
end
