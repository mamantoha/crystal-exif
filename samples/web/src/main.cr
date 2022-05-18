require "kemal"
require "exif"

get "/" do
  render "src/views/index.ecr"
end

post "/upload" do |env|
  file = env.params.files["fileToUpload"].tempfile

  content = file.gets_to_end
  encoded = Base64.encode(content)

  exif = Exif.new(file)
  data = exif.data
  data = data.transform_keys(&.camelcase)

  render "src/views/show.ecr"
end

Kemal.run
