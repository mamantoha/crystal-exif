require "./exif/**"

class Exif
  def initialize(input : String)
    @data_ptr = LibExif.exif_data_new_from_file(input)

    # tag = LibExif::ExifTag::ExifTagInteroperabilityVersion
    # entry_ptr = LibExif.exif_content_get_entry(@data_ptr.value.ifd[LibExif::ExifIfd::ExifIfdGps.value], tag)
    # value_ptr = LibExif.exif_entry_get_value(entry_ptr, out buf, 32)
    # p! value_ptr
    # value = String.new(value_ptr)
    # p! value
  end

  def to_h
    tags = {} of String => String

    LibExif::ExifTag.each do |tag, _|
      attr = tag.to_s.lchop("ExifTag").underscore

      entry_ptr = exif_data_get_entry(tag)

      next unless entry_ptr

      value_ptr = LibExif.exif_entry_get_value(entry_ptr, out buf, 32)
      value = String.new(value_ptr)

      tags[attr] = value.strip
    end

    tags
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
