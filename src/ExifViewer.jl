module ExifViewer

include("../lib/LibExif.jl")
using .LibExif

include("utils.jl")
include("read.jl")
include("write.jl")

export read_tags, write_tags

end
