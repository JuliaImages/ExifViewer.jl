module ExifViewer

include("../lib/LibExif.jl")
using .LibExif

using ColorTypes
using JpegTurbo

include("utils.jl")
include("read.jl")
include("write.jl")

export read_tags, write_tags

end
