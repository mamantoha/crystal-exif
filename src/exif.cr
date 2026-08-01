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

  def initialize(data : Bytes)
    loader = LibExif.exif_loader_new
    raise Error.new("Unable to load EXIF data") if loader.null?

    begin
      LibExif.exif_loader_write(loader, data.to_unsafe, data.size.to_u32)
      data_ptr = LibExif.exif_loader_get_data(loader)
    ensure
      LibExif.exif_loader_unref(loader)
    end

    initialize(data_ptr)
  end

  def initialize(io : IO)
    buffer = IO::Memory.new
    IO.copy(io, buffer)
    initialize(buffer.to_slice)
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

  def entries : Array(Entry)
    entries = [] of Entry

    LibExif::ExifIfd.values.each do |ifd|
      next if ifd == LibExif::ExifIfd::ExifIfdCount

      content = @data_ptr.value.ifd[ifd.value]
      next if content.null?

      content.value.count.times do |index|
        entry_ptr = content.value.entries[index]
        next if entry_ptr.null?

        entries << Entry.new(self, ifd, entry_ptr)
      end
    end

    entries
  end

  def entry(tag : LibExif::ExifTag, ifd : LibExif::ExifIfd? = nil) : Entry?
    if ifd
      return entry_in_ifd(tag, ifd)
    end

    exif_ifds(tag).each do |candidate_ifd|
      if found_entry = entry_in_ifd(tag, candidate_ifd)
        return found_entry
      end
    end
  end

  private def load_data
    LibExif::ExifTag.values.each do |tag|
      entry = entry(tag)

      next unless entry

      attr = tag.to_s.lchop("ExifTag").underscore
      @data[attr] = entry.display_value.strip
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

  private def entry_in_ifd(tag : LibExif::ExifTag, ifd : LibExif::ExifIfd) : Entry?
    content = @data_ptr.value.ifd[ifd.value]
    return if content.null?

    entry_ptr = LibExif.exif_content_get_entry(content, tag)
    Entry.new(self, ifd, entry_ptr) unless entry_ptr.null?
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
