using ExifViewer
import ExifViewer.LibExif as LE
using Test, TestImages

filepath = testimage("earth_apollo17.jpg",download_only=true)

include("libexif.jl")
include("exifviewer.jl")