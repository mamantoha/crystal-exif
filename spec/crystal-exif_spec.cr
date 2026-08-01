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

  def byte_order_for_spec=(order : LibExif::ExifByteOrder)
    LibExif.exif_data_set_byte_order(@data_ptr, order)
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

    it "decodes typed numeric values" do
      exif = Exif.new(path)

      exif.entry(LibExif::ExifTag::ExifTagOrientation).as(Exif::Entry).short.should eq(1_u16)
      exif.entry(LibExif::ExifTag::ExifTagPixelXDimension).as(Exif::Entry).long.should eq(640_u32)

      resolution = exif.entry(LibExif::ExifTag::ExifTagXResolution).as(Exif::Entry).rational
      resolution.numerator.should eq(300_u32)
      resolution.denominator.should eq(1_u32)

      exposure_bias = exif.entry(LibExif::ExifTag::ExifTagExposureBiasValue).as(Exif::Entry).srational
      exposure_bias.numerator.should eq(0)
      exposure_bias.denominator.should eq(10)

      latitude = exif.entry(LibExif::ExifTag::ExifTagGpsLatitude).as(Exif::Entry)
      latitude.rational(0).numerator.should eq(43_u32)
      latitude.rational(1).numerator.should eq(28_u32)
      latitude.rational(2).numerator.should eq(281_400_000_u32)
    end

    it "respects the EXIF byte order" do
      exif = Exif.new(path)
      entry = exif.entry(LibExif::ExifTag::ExifTagPixelXDimension).as(Exif::Entry)

      exif.byte_order.should eq(LibExif::ExifByteOrder::ExifByteOrderIntel)
      entry.raw_bytes.should eq(Bytes[128, 2, 0, 0])

      exif.byte_order_for_spec = LibExif::ExifByteOrder::ExifByteOrderMotorola

      exif.byte_order.should eq(LibExif::ExifByteOrder::ExifByteOrderMotorola)
      entry.raw_bytes.should eq(Bytes[0, 0, 2, 128])
      entry.long.should eq(640_u32)
    end

    it "rejects incompatible formats and component indexes" do
      exif = Exif.new(path)
      orientation = exif.entry(LibExif::ExifTag::ExifTagOrientation).as(Exif::Entry)
      latitude = exif.entry(LibExif::ExifTag::ExifTagGpsLatitude).as(Exif::Entry)

      expect_raises(Exif::Error, /Cannot decode .*ExifFormatShort.*ExifFormatLong/) do
        orientation.long
      end

      expect_raises(Exif::Error, "Component index 3 is out of bounds for 3 components") do
        latitude.rational(3)
      end
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
