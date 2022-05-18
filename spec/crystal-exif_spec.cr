require "./spec_helper"

describe Exif do
  file = File.open("#{__DIR__}/fixtures/metadata_test.jpg")
  path = file.path

  context Exif::VERSION do
    Exif::VERSION.should_not be_nil
  end

  context "initialize" do
    it "success with a file" do
      exif = Exif.new(file)

      data = exif.data

      data["compression"].should eq("JPEG compression")
    end

    it "success with a path" do
      exif = Exif.new(file.path)

      data = exif.data

      data["compression"].should eq("JPEG compression")
    end

    it "raise an error if file does not exists" do
      expect_raises File::NotFoundError, "Error opening file: '/not/found': No such file" do
        Exif.new("/not/found")
      end
    end
  end

  it ".data" do
    exif = Exif.new(path)

    data = exif.data

    data["compression"].should eq("JPEG compression")
    data["image_description"].should eq("")
    data["make"].should eq("NIKON")
    data["model"].should eq("COOLPIX P6000")
    data["user_comment"].should eq("")
    data["gps_latitude"].should eq("43, 28, 2.81400000")
    data["gps_longitude"].should eq("11, 53, 6.45599999")
  end

  it ".mnote_data" do
    exif = Exif.new(path)

    mnote_data = exif.mnote_data

    mnote_data["Firmware"].should eq("0210")
    mnote_data["CaptureEditorVer"].should eq("COOLPIX P6000V1.0")
  end

  context "issues" do
    it "should ot raise Invalid memory access" do
      1024.times do
        exif = Exif.new(path)
        exif.data
        exif.mnote_data
      end
    end
  end

  context "no EXIF mnote data" do
    it "returns empty mnote data" do
      file = File.open("#{__DIR__}/fixtures/nan.jpg")
      exif = Exif.new(file)

      exif.mnote_data.should be_empty
    end
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
