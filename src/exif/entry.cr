class Exif
  class Entry
    getter ifd : LibExif::ExifIfd

    protected def initialize(
      @owner : Exif,
      @ifd : LibExif::ExifIfd,
      @entry_ptr : Pointer(LibExif::ExifEntry),
    )
    end

    def tag : LibExif::ExifTag
      @entry_ptr.value.tag
    end

    def format : LibExif::ExifFormat
      @entry_ptr.value.format
    end

    def components : LibC::ULong
      @entry_ptr.value.components
    end

    def size : LibC::UInt
      @entry_ptr.value.size
    end

    def raw_bytes : Bytes
      entry = @entry_ptr.value
      Bytes.new(entry.size.to_i) { |index| entry.data[index] }
    end

    def short(index = 0) : UInt16
      LibExif.exif_get_short(component_data(LibExif::ExifFormat::ExifFormatShort, 2, index), @owner.byte_order)
    end

    def sshort(index = 0) : Int16
      LibExif.exif_get_sshort(component_data(LibExif::ExifFormat::ExifFormatSshort, 2, index), @owner.byte_order)
    end

    def long(index = 0) : UInt32
      LibExif.exif_get_long(component_data(LibExif::ExifFormat::ExifFormatLong, 4, index), @owner.byte_order)
    end

    def slong(index = 0) : Int32
      LibExif.exif_get_slong(component_data(LibExif::ExifFormat::ExifFormatSlong, 4, index), @owner.byte_order)
    end

    def rational(index = 0) : LibExif::ExifRational
      LibExif.exif_get_rational(component_data(LibExif::ExifFormat::ExifFormatRational, 8, index), @owner.byte_order)
    end

    def srational(index = 0) : LibExif::ExifSRational
      LibExif.exif_get_srational(component_data(LibExif::ExifFormat::ExifFormatSrational, 8, index), @owner.byte_order)
    end

    def display_value : String
      buffer_size = BUFFER_SIZE

      loop do
        buffer = Bytes.new(buffer_size)
        value_ptr = LibExif.exif_entry_get_value(@entry_ptr, buffer.to_unsafe, buffer_size.to_u32)
        return "" if value_ptr.null?

        value = String.new(value_ptr)
        return value if value.bytesize < buffer_size - 1

        buffer_size *= 2
      end
    end

    private def component_data(expected_format : LibExif::ExifFormat, component_size : Int32, index : Int32) : UInt8*
      unless format == expected_format
        raise Error.new("Cannot decode #{format} entry as #{expected_format}")
      end

      unless 0 <= index < components
        raise Error.new("Component index #{index} is out of bounds for #{components} components")
      end

      offset = index * component_size
      entry = @entry_ptr.value
      if entry.data.null? || offset + component_size > entry.size
        raise Error.new("Invalid data size for #{format} entry")
      end

      entry.data + offset
    end
  end
end
