# crystal-exif

[![Crystal CI](https://github.com/mamantoha/crystal-exif/actions/workflows/crystal.yml/badge.svg)](https://github.com/mamantoha/crystal-exif/actions/workflows/crystal.yml)

Crystal C bindings for libexif.
Provides basic support for reading EXIF tags on files using libexif and Crystal.

## Installation

Get libexif for your OS:

```
# MacOS
brew install libexif

# Debian/Ubuntu
apt-get install -y libexif-dev

# RedHat/Fedora
dnf install -y libexif-devel
```

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  crystal-exif:
    github: mamantoha/crystal-exif
```

Run `shards install`

## Usage

This is an example on how to read EXIF data from a file:

```crystal
require "crystal-exif"
```

![metadata_test.jpg](/spec/fixtures/metadata_test.jpg)

The image is taken from [exif-samples](https://github.com/ianare/exif-samples) repository.

### Load EXIF data from a JPEG file

```crystal
file = File.open("metadata_test.jpg")
exif = Exif.new(file)
exif.data
```

```crystal
{"compression" => "JPEG compression",
 "image_description" => "",
 "make" => "NIKON",
 "model" => "COOLPIX P6000",
 "orientation" => "Top-left",
 "x_resolution" => "300",
 "y_resolution" => "300",
 "resolution_unit" => "Inch",
 "software" => "Nikon Transfer 1.1 W",
 "date_time" => "2008:11:01 21:15:07",
 "ycbcr_positioning" => "Centered",
 "exposure_time" => "1/75 sec.",
 "fnumber" => "f/5.9",
 "exposure_program" => "Normal program",
 "iso_speed_ratings" => "64",
 "exif_version" => "Exif Version 2.2",
 "date_time_original" => "2008:10:22 16:28:39",
 "date_time_digitized" => "2008:10:22 16:28:39",
 "components_configuration" => "Y Cb Cr -",
 "exposure_bias_value" => "0.00 EV",
 "max_aperture_value" => "2.90 EV (f/2.7)",
 "metering_mode" => "Pattern",
 "light_source" => "Unknown",
 "flash" => "Flash did not fire, compulsory flash mode",
 "focal_length" => "24.0 mm",
 "maker_note" => "3298 bytes undefined data",
 "user_comment" => "",
 "flash_pix_version" => "FlashPix Version 1.0",
 "color_space" => "sRGB",
 "pixel_x_dimension" => "640",
 "pixel_y_dimension" => "480",
 "file_source" => "DSC",
 "scene_type" => "Directly photographed",
 "custom_rendered" => "Normal process",
 "exposure_mode" => "Auto exposure",
 "white_balance" => "Auto white balance",
 "digital_zoom_ratio" => "0.00",
 "focal_length_in35_mm_film" => "112",
 "scene_capture_type" => "Standard",
 "gain_control" => "Normal",
 "contrast" => "Normal",
 "saturation" => "Normal",
 "sharpness" => "Normal",
 "subject_distance_range" => "Unknown",
 "gps_latitude_ref" => "N",
 "gps_latitude" => "43, 28, 2.81400000",
 "gps_longitude_ref" => "E",
 "gps_longitude" => "11, 53, 6.45599999",
 "gp_altitude_ref" => "Sea level",
 "gps_time_stamp" => "14:27:07.24",
 "gps_satellites" => "06",
 "gps_img_direction_ref" => "",
 "gps_map_datum" => "WGS-84",
 "gps_date_stamp" => "2008:10:23"}
```

### Return an Exif entry for the given tag

```crystal
file = File.open("metadata_test.jpg")
exif = Exif.new(file)
exif.make # => "NIKON"
exif.model # => "COOLPIX P6000"
```

### Return the MakerNote data out of the EXIF data

```crystal
file = File.open("metadata_test.jpg")
exif = Exif.new(file)
exif.mnote_data
```

```crystal
{"Firmware" => "0210",
 "ISO" => "ISO 0",
 "ColorMode1" => "COLOR",
 "Quality" => "FINE",
 "WhiteBalance" => "AUTO",
 "Sharpening" => "NORMAL",
 "FocusMode" => "AF-S",
 "FlashSetting" => "",
 "ISOSelection" => "AUTO",
 "FaceDetect" => "8 bytes unknown data: 01004001f0000000",
 "ActiveDLighting" => "0",
 "ImageAdjustment" => "NORMAL",
 "ToneCompensation" => "NORMAL",
 "Adapter" => "OFF",
 "DigitalZoom" => "1.000",
 "AFFocusPosition" => "AF position: center",
 "ShotInfo" => "18 bytes unknown data: 000000000e00000000000000000044430000",
 "Saturation" => "0",
 "NoiseReduction," => "OFF",
 "RetouchHistory" => "Invalid number of components (6, expected 1).",
 "Saturation2" => "NORMAL",
 "CaptureEditorVer" => "COOLPIX P6000V1.0"}
```

## Development

```
crystal ./lib/crystal_lib/src/main.cr src/exif/lib_exif.cr.in > src/exif/lib_exif.cr
```

## Contributing

1. Fork it (<https://github.com/mamantoha/crystal-exif/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anton Maminov](https://github.com/mamantoha) - creator and maintainer
