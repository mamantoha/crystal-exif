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

  context "no EXIF data" do
    it "returns empty data and mnote data" do
      expected_data = {
        "x_resolution"      => "72",
        "y_resolution"      => "72",
        "resolution_unit"   => "Inch",
        "exif_version"      => "Exif Version 2.1",
        "flash_pix_version" => "FlashPix Version 1.0",
        "color_space"       => "Uncalibrated",
      }

      file = File.open("#{__DIR__}/fixtures/nan.jpg")
      exif = Exif.new(file)

      data = exif.data

      data.keys.should eq(
        [
          "x_resolution",
          "y_resolution",
          "resolution_unit",
          "exif_version",
          "flash_pix_version",
          "color_space",
        ]
      )

      data["x_resolution"].should eq(expected_data["x_resolution"])
      data["y_resolution"].should eq(expected_data["y_resolution"])
      data["resolution_unit"].should eq(expected_data["resolution_unit"])
      data["exif_version"].should eq(expected_data["exif_version"])
      data["flash_pix_version"].should eq(expected_data["flash_pix_version"])

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
