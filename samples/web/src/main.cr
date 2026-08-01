require "mime"
require "kemal"
require "exif"
require "html"

RAW_PREVIEW_SIZE = 128
MAX_UPLOAD_SIZE  = 32 * 1024 * 1024

Kemal.config.max_request_body_size = MAX_UPLOAD_SIZE

struct EntryDetails
  getter tag : String
  getter tag_id : Int32
  getter ifd : String
  getter format : String
  getter components : LibC::ULong
  getter size : LibC::UInt
  getter value : String
  getter raw_bytes : String
  getter raw_truncated : Bool

  def initialize(
    @tag : String,
    @tag_id : Int32,
    @ifd : String,
    @format : String,
    @components : LibC::ULong,
    @size : LibC::UInt,
    @value : String,
    @raw_bytes : String,
    @raw_truncated : Bool,
  )
  end
end

def entry_details(entry : Exif::Entry) : EntryDetails
  bytes = entry.raw_bytes
  preview_size = Math.min(bytes.size, RAW_PREVIEW_SIZE)

  EntryDetails.new(
    tag: entry.tag.to_s.lchop("ExifTag"),
    tag_id: entry.tag.value,
    ifd: entry.ifd.to_s.lchop("ExifIfd"),
    format: entry.format.to_s.lchop("ExifFormat"),
    components: entry.components,
    size: entry.size,
    value: entry.display_value,
    raw_bytes: bytes[0, preview_size].hexstring,
    raw_truncated: bytes.size > preview_size,
  )
end

get "/" do
  upload_error = nil
  render "src/views/index.ecr"
end

error 413 do
  upload_error = "The image is too large. The maximum upload size is 32 MB."
  render "src/views/index.ecr"
end

post "/upload" do |env|
  file = env.params.files["fileToUpload"].tempfile
  filename = env.params.files["fileToUpload"].filename

  mime_type = filename ? MIME.from_filename(filename) : "image/jpeg"

  content = file.gets_to_end
  encoded = Base64.encode(content)

  data = {} of String => String
  mnote_data = {} of String => String
  entries = [] of EntryDetails
  byte_order = nil
  error_message = nil

  begin
    file.rewind
    exif = Exif.new(file)
    data = exif.data.transform_keys(&.camelcase)
    mnote_data = exif.mnote_data
    entries = exif.entries.map { |entry| entry_details(entry) }
    byte_order = exif.byte_order.to_s.lchop("ExifByteOrder")
  rescue Exif::Error
    error_message = "This image does not contain readable EXIF metadata."
  end

  render "src/views/show.ecr"
end

Kemal.run
