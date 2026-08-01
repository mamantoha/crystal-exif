require "./spec_helper"

class Exif
  def read_value_for_spec(value : String) : String
    bytes = value.to_slice

    read_value do |buffer, maxlen|
      count = Math.min(bytes.size, maxlen.to_i - 1)
      bytes.to_unsafe.copy_to(buffer, count)
      buffer[count] = 0_u8
      buffer
    end
  end

  def remove_gps_entries_and_reload
    content = @data_ptr.value.ifd[LibExif::ExifIfd::ExifIfdGps.value]

    while content.value.count > 0
      LibExif.exif_content_remove_entry(content, content.value.entries[0])
    end

    @data.clear
    load_data
    @data
  end
end

describe Exif do
  path = "#{__DIR__}/fixtures/metadata_test.jpg"

  context Exif::VERSION do
    Exif::VERSION.should_not be_nil
  end

  context "initialize" do
    it "initializes with a file" do
      File.open(path) do |file|
        exif = Exif.new(file)

        data = exif.data

        data["compression"].should eq("JPEG compression")
      end
    end

    it "initializes with bytes" do
      exif = Exif.new(File.read(path).to_slice)

      exif.model.should eq("COOLPIX P6000")
    end

    it "initializes with an IO" do
      io = IO::Memory.new(File.read(path))
      exif = Exif.new(io)

      exif.model.should eq("COOLPIX P6000")
      io.pos.should eq(io.size)
    end

    it "initializes with a path" do
      exif = Exif.new(path)

      data = exif.data

      data["compression"].should eq("JPEG compression")
    end

    it "raises an error if the file does not exist" do
      expect_raises File::NotFoundError, "Error opening file: '/not/found': No such file" do
        Exif.new("/not/found")
      end
    end

    it "raises an error if EXIF data cannot be loaded" do
      expect_raises Exif::Error, "Unable to load EXIF data" do
        Exif.new("#{__DIR__}/fixtures/nan.jpg")
      end
    end

    it "raises the same error for a file without EXIF data" do
      File.open("#{__DIR__}/fixtures/nan.jpg") do |file|
        expect_raises Exif::Error, "Unable to load EXIF data" do
          Exif.new(file)
        end
      end
    end

    it "raises the same error for bytes without EXIF data" do
      expect_raises Exif::Error, "Unable to load EXIF data" do
        Exif.new(Bytes.empty)
      end
    end
  end

  it "#data" do
    exif = Exif.new(path)

    data = exif.data

    data["compression"].should eq("JPEG compression")
    data["image_description"].should eq("")
    data["make"].should eq("NIKON")
    data["model"].should eq("COOLPIX P6000")
    data["user_comment"].should eq("")
    data["gps_latitude"].should eq("43, 28, 2.81400000")
    data["gps_longitude"].should eq("11, 53, 6.45599999")
    data["gps_altitude_ref"].should eq("Sea level")
  end

  describe "#entry" do
    it "returns a typed entry" do
      exif = Exif.new(path)
      entry = exif.entry(LibExif::ExifTag::ExifTagModel).as(Exif::Entry)

      entry.tag.should eq(LibExif::ExifTag::ExifTagModel)
      entry.ifd.should eq(LibExif::ExifIfd::ExifIfd0)
      entry.format.should eq(LibExif::ExifFormat::ExifFormatAscii)
      entry.components.should eq(entry.raw_bytes.size)
      entry.display_value.should eq("COOLPIX P6000")
      String.new(entry.raw_bytes.to_unsafe).should eq("COOLPIX P6000")
    end

    it "can restrict lookup to an IFD" do
      exif = Exif.new(path)
      tag = LibExif::ExifTag::ExifTagGpsLatitude

      exif.entry(tag, LibExif::ExifIfd::ExifIfd0).should be_nil
      entry = exif.entry(tag, LibExif::ExifIfd::ExifIfdGps).as(Exif::Entry)
      entry.ifd.should eq(LibExif::ExifIfd::ExifIfdGps)
    end

    it "keeps its EXIF data alive" do
      entry = Exif.new(path).entry(LibExif::ExifTag::ExifTagModel).as(Exif::Entry)

      GC.collect

      entry.display_value.should eq("COOLPIX P6000")
    end
  end

  it "#entries" do
    entries = Exif.new(path).entries

    entries.should_not be_empty
    entries.any? { |entry| entry.tag == LibExif::ExifTag::ExifTagModel }.should be_true
    entries.none? { |entry| entry.ifd == LibExif::ExifIfd::ExifIfdCount }.should be_true
  end

  it "#mnote_data" do
    exif = Exif.new(path)

    mnote_data = exif.mnote_data

    mnote_data["Firmware"].should eq("0210")
    mnote_data["CaptureEditorVer"].should eq("COOLPIX P6000V1.0")

    3.times do
      exif.mnote_data.should eq(mnote_data)
    end
  end

  context "regressions" do
    it "finalizes native data safely" do
      read_exif = -> do
        exif = Exif.new(path)
        exif.data
        3.times { exif.mnote_data }
      end

      100.times do
        read_exif.call
        GC.collect
      end
    end

    it "does not read interoperability tags as GPS tags" do
      exif = Exif.new(path)

      data = exif.remove_gps_entries_and_reload

      data["gps_latitude_ref"]?.should be_nil
      data["gps_latitude"]?.should be_nil
    end

    it "does not truncate values larger than the initial buffer" do
      exif = Exif.new(path)
      value = "x" * (Exif::BUFFER_SIZE * 2)

      exif.read_value_for_spec(value).should eq(value)
    end
  end

  context "instance methods" do
    it "#model" do
      exif = Exif.new(path)

      exif.model.should eq("COOLPIX P6000")
    end

    it "#gps_latitude" do
      exif = Exif.new(path)

      exif.gps_latitude.should eq("43, 28, 2.81400000")
    end

    it "#gps_altitude_ref" do
      exif = Exif.new(path)

      exif.gps_altitude_ref.should eq("Sea level")
    end
  end
end
