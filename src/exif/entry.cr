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
  end
end
