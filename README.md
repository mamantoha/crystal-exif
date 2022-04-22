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
