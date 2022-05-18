require "mime"
require "kemal"
require "exif"

get "/" do
  render "src/views/index.ecr"
end

post "/upload" do |env|
  file = env.params.files["fileToUpload"].tempfile
  filename = env.params.files["fileToUpload"].filename

  mime_type = filename ? MIME.from_filename(filename) : "image/jpeg"

  content = file.gets_to_end
  encoded = Base64.encode(content)

  exif = Exif.new(file)
  data = exif.data
  data = data.transform_keys(&.camelcase)

  render "src/views/show.ecr"
end

Kemal.run
