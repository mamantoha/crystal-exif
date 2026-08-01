require "./exif/**"

class Exif
  class Error < Exception
  end

  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  BUFFER_SIZE = 1024

  getter data

  @data = {} of String => String
  @mnote_data = {} of String => String
  @mnote_data_loaded = false

  def initialize(path : String)
    unless File.exists?(path)
      raise File::NotFoundError.new("Error opening file: '#{path}': No such file", file: path)
    end

    data_ptr = LibExif.exif_data_new_from_file(path)

    initialize(data_ptr)
  end

  def initialize(file : File)
    data_ptr = LibExif.exif_data_new_from_data(File.read(file.path), file.size)

    initialize(data_ptr)
  end

  private def initialize(@data_ptr : Pointer(LibExif::ExifData))
    raise Error.new("Unable to load EXIF data") if @data_ptr.null?

    LibExif.exif_data_fix(@data_ptr)

    @mnote_data_ptr = LibExif.exif_data_get_mnote_data(@data_ptr)

    load_data
  end

  {% for name, _index in LibExif::ExifTag.constants %}
    {% attr = name.gsub(/^ExifTag/, "").underscore %}
    def {{ attr.id }} : String?
      @data["{{ attr }}"]?
    end
  {% end %}

  private def load_data
    LibExif::ExifTag.values.each do |tag|
      entry_ptr = exif_data_get_entry(tag)

      next unless entry_ptr

      attr = tag.to_s.lchop("ExifTag").underscore

      value = read_value do |buffer, maxlen|
        LibExif.exif_entry_get_value(entry_ptr, buffer, maxlen)
      end

      @data[attr] = value.strip
    end
  end

  def mnote_data : Hash(String, String)
    return @mnote_data if @mnote_data_loaded

    num = LibExif.exif_mnote_data_count(@mnote_data_ptr)

    # Loop through all MakerNote tags
    (0...num).each do |i|
      mnote_data_name_ptr = LibExif.exif_mnote_data_get_name(@mnote_data_ptr, i)

      next unless mnote_data_name_ptr

      name = String.new(mnote_data_name_ptr)

      value = read_value do |buffer, maxlen|
        LibExif.exif_mnote_data_get_value(@mnote_data_ptr, i, buffer, maxlen)
      end

      @mnote_data[name] = value.strip
    end

    @mnote_data_loaded = true
    @mnote_data
  end

  private def read_value(& : UInt8*, LibC::UInt -> UInt8*) : String
    buffer_size = BUFFER_SIZE

    loop do
      buffer = Bytes.new(buffer_size)
      value_ptr = yield buffer.to_unsafe, buffer_size.to_u32
      return "" if value_ptr.null?

      value = String.new(value_ptr)
      return value if value.bytesize < buffer_size - 1

      buffer_size *= 2
    end
  end

  private def exif_data_get_entry(tag : LibExif::ExifTag) : LibExif::ExifEntry*?
    exif_ifds(tag).each do |ifd|
      exif_entry = LibExif.exif_content_get_entry(@data_ptr.value.ifd[ifd.value], tag)

      return exif_entry if exif_entry
    end
  end

  private def exif_ifds(tag : LibExif::ExifTag) : Array(LibExif::ExifIfd)
    if tag.to_s.starts_with?("ExifTagGps")
      return [LibExif::ExifIfd::ExifIfdGps]
    end

    LibExif::ExifIfd.values.reject do |ifd|
      ifd == LibExif::ExifIfd::ExifIfdCount || LibExif.exif_tag_get_name_in_ifd(tag, ifd).null?
    end
  end

  def finalize
    LibExif.exif_data_unref(@data_ptr)
  end
end
