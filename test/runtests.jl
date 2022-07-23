using ExifViewer
import ExifViewer.LibExif as LE
using Test, TestImages
using Downloads


filepath = testimage("earth_apollo17.jpg",download_only=true)
_wrap(name, num) = "https://github.com/ashwani-rathee/exif-sampleimages/blob/main/$(name)_makernote_variant_$num.jpg?raw=true"
get_example(x, y) = Downloads.download(_wrap(x, y))

include("libexif.jl")
include("exifviewer.jl")