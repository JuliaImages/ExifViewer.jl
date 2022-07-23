module ExifViewer

include("../lib/LibExif.jl")
using .LibExif

include("utils.jl")
include("read.jl")

export read_tags

end
