require "./exif/**"

class Exif
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  BUFFER_SIZE = 1024

  getter data

  @data = {} of String => String
  @mnote_data = {} of String => String

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
    LibExif.exif_data_ref(@data_ptr)
    LibExif.exif_data_fix(@data_ptr)

    @mnote_data_ptr = LibExif.exif_data_get_mnote_data(@data_ptr)

    LibExif.exif_mnote_data_ref(@mnote_data_ptr) unless @mnote_data_ptr.null?

    load_data
  end

  {% for name, _index in LibExif::ExifTag.constants %}
    {% attr = name.gsub(/^ExifTag/, "").underscore %}
    def {{attr.id}} : String?
      @data["{{attr}}"]?
    end
  {% end %}

  private def load_data
    buffer = uninitialized UInt8[BUFFER_SIZE]
    buffer_ptr = buffer.to_unsafe

    LibExif::ExifTag.values.each do |tag|
      entry_ptr = exif_data_get_entry(tag)

      next unless entry_ptr

      attr = tag.to_s.lchop("ExifTag").underscore

      value_ptr = LibExif.exif_entry_get_value(entry_ptr, buffer_ptr, BUFFER_SIZE)

      value = String.new(value_ptr)

      @data[attr] = value.strip
    end
  end

  def mnote_data : Hash(String, String)
    return @mnote_data unless @mnote_data.empty?

    num = LibExif.exif_mnote_data_count(@mnote_data_ptr)

    buffer = uninitialized UInt8[BUFFER_SIZE]
    buffer_ptr = buffer.to_unsafe

    # Loop through all MakerNote tags
    (0...num).each do |i|
      mnote_data_name_ptr = LibExif.exif_mnote_data_get_name(@mnote_data_ptr, i)

      next unless mnote_data_name_ptr

      name = String.new(mnote_data_name_ptr)

      mnote_data_value_ptr = LibExif.exif_mnote_data_get_value(@mnote_data_ptr, i, buffer_ptr, BUFFER_SIZE)
      value = String.new(mnote_data_value_ptr)

      @mnote_data[name] = value.strip
    end

    @mnote_data
  ensure
    LibExif.exif_mnote_data_unref(@mnote_data_ptr)
  end

  private def exif_data_get_entry(tag : LibExif::ExifTag) : LibExif::ExifEntry*?
    ifds = LibExif::ExifIfd.values.reject(LibExif::ExifIfd::ExifIfdCount)

    ifds.each do |ifd|
      exif_entry = LibExif.exif_content_get_entry(@data_ptr.value.ifd[ifd.value], tag)

      return exif_entry if exif_entry
    end
  end

  def finalize
    LibExif.exif_data_unref(@data_ptr)
    LibExif.exif_data_free(@data_ptr)
  end
end
