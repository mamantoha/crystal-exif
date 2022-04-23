require "./exif/**"

class Exif
  getter data

  @data = {} of String => String
  @mnote_data = {} of String => String

  def initialize(@path : String)
    @data_ptr = LibExif.exif_data_new_from_file(@path)
    @mnote_data_ptr = LibExif.exif_data_get_mnote_data(@data_ptr)
    @buf = uninitialized UInt8

    load_data
  end

  {% for name, _index in LibExif::ExifTag.constants %}
    {% attr = name.gsub(/^ExifTag/, "").underscore %}
    def {{attr.id}} : String?
      @data["{{attr}}"]?
    end
  {% end %}

  private def load_data
    LibExif::ExifTag.each do |tag, _|
      attr = tag.to_s.lchop("ExifTag").underscore

      entry_ptr = exif_data_get_entry(tag)

      next unless entry_ptr

      value_ptr = LibExif.exif_entry_get_value(entry_ptr, out buf, 64)
      value = String.new(value_ptr)

      @data[attr] = value.strip
    end
  end

  def mnote_data : Hash(String, String)
    return @mnote_data unless @mnote_data.empty?

    num = LibExif.exif_mnote_data_count(@mnote_data_ptr)

    # Loop through all MakerNote tags
    (0...num).each do |i|
      mnote_data_name_ptr = LibExif.exif_mnote_data_get_name(@mnote_data_ptr, i)

      next unless mnote_data_name_ptr

      mnote_data_value_ptr = LibExif.exif_mnote_data_get_value(@mnote_data_ptr, i, pointerof(@buf), 64)
      value = String.new(mnote_data_value_ptr)

      name = String.new(mnote_data_name_ptr)

      @mnote_data[name] = value.strip
    end

    @mnote_data
  end

  private def exif_data_get_entry(tag : LibExif::ExifTag) : LibExif::ExifEntry*?
    case
    when (e = LibExif.exif_content_get_entry(@data_ptr.value.ifd[LibExif::ExifIfd::ExifIfd0.value], tag))
      e
    when (e = LibExif.exif_content_get_entry(@data_ptr.value.ifd[LibExif::ExifIfd::ExifIfd1.value], tag))
      e
    when (e = LibExif.exif_content_get_entry(@data_ptr.value.ifd[LibExif::ExifIfd::ExifIfdExif.value], tag))
      e
    when (e = LibExif.exif_content_get_entry(@data_ptr.value.ifd[LibExif::ExifIfd::ExifIfdGps.value], tag))
      e
    when (e = LibExif.exif_content_get_entry(@data_ptr.value.ifd[LibExif::ExifIfd::ExifIfdInteroperability.value], tag))
      e
    else
      nil
    end
  end
end
