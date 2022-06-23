module ExifViewer

include("../lib/LibExif.jl")
include("tags.jl") # for simple names

using .LibExif

export read_metadata, read_tags

## Tasks 
# We want to read from IO, data, filepath : done
# We want to give option of reading specific id and specific tags too
# We want to make it fast
# We want docs and we want tests
# We want to ensure pointer gets removed after information
function numifds(ed::LibExif._ExifData)
    return length(ed.ifd)
end

function numentriesinifd(data::LibExif._ExifContent)
    return Int(data.count)
end



"""
    read_metadata(data::Vector{UInt8}; kwargs...)
    read_metadata(filepath::AbstractString; kwargs...)
    read_metadata(io::IO; kwargs...)

Reads EXIF data from a filepath, IO, vector{Int8} and returns a Dict with tags and their values.

# Examples
```jldoctest
julia> using BenchmarkTools, TestImages, ExifViewer
julia> filename = "test/test_images/test.jpg"

julia> io = open(filename, "r")
julia> read_metadata(io)
Dict{Any, Any} with 12 entries:
  "EXIF_TAG_DOCUMENT_NAME"     => "Test_Image"
  "EXIF_TAG_ORIENTATION"       => "Bottom-right"
  ⋮                            => ⋮

julia> read_metadata(filename)
Dict{Any, Any} with 12 entries:
  "EXIF_TAG_DOCUMENT_NAME"     => "Test_Image"
  "EXIF_TAG_ORIENTATION"       => "Bottom-right"
  ⋮                            => ⋮

julia> a = read("test/test_images/test.jpg")
julia> read_metadata(a)
Dict{Any, Any} with 12 entries:
  "EXIF_TAG_DOCUMENT_NAME"     => "Test_Image"
  "EXIF_TAG_ORIENTATION"       => "Bottom-right"
  ⋮                            => ⋮

```


```julia
julia> using BenchmarkTools, TestImages, ExifViewer
julia> filename = "test/test_images/test.jpg"

julia> io = open(filename, "r")
julia> @btime read_metadata(io)
1.862 μs (11 allocations: 912 bytes)

julia> @btime read_metadata(filename)
269.472 μs (122 allocations: 100.05 KiB)

julia> @btime data = read(filename)
15.876 μs (13 allocations: 69.28 KiB)

julia> @btime read_metadata(data)
221.786 μs (109 allocations: 30.77 KiB)
```
"""
function read_metadata(data::Vector{UInt8}; ifds::Union{Int, NTuple, UnitRange}=1)
    ed_ptr = LibExif.exif_data_new_from_data(data, length(data))
    # handle case where ed_ptr is null
    if(ed_ptr == C_NULL)
        return error("Unable to read EXIF data")
    end
    ed = unsafe_load(ed_ptr)
    ifds = collect(1:numifds(ed)) # reads all
    # ifds = collect(ifds) # assumes user knows what they are doing
    result = Dict()
    for i in ifds
        content_ptr = ed.ifd[i] # ques: do we need to unref these too?
        # handle case where content_ptr is null
        if(content_ptr == C_NULL)
            return error("Unable to read IFD:",i)
        end
        data = unsafe_load(content_ptr)
        res = unsafe_wrap(Array, data.entries, data.count)
        for i in 1:data.count
            str = Vector{Cuchar}(undef, 1024);
            LibExif.exif_entry_get_value(Ref(unsafe_load(res[i])), str, length(str))
            result[string(unsafe_load(res[i]).tag)] = rstrip(String(str), '\0')
        end
    end
    LibExif.exif_data_unref(ed_ptr);
    return result
end

read_metadata(filepath::AbstractString; kwargs...) = read_metadata(read(filepath); kwargs...)
read_metadata(io::IO; kwargs...) = read_metadata(read(io); kwargs...)

"""
    read_tags(data::Vector{UInt8}; tags::Vector{LibExif.ExifTag}
    read_tags(filepath::AbstractString; kwargs...)
    read_tags(io::IO; kwargs...)

Reads single or multiple tags from the EXIF data.
"""
function read_tags(data::Vector{UInt8}; tags::Vector{LibExif.ExifTag})
    ed_ptr = LibExif.exif_data_new_from_data(data, length(data))
    # handle case where ed_ptr is null
    if(ed_ptr == C_NULL)
        return error("Unable to read EXIF data")
    end
    ed = unsafe_load(ed_ptr)
    ifds = collect(1:numifds(ed)) # reads all
    result = Dict()
    tags = Set(tags)
    for i in ifds
        content_ptr = ed.ifd[i] # ques: do we need to unref these too?
        # handle case where content_ptr is null
        if(content_ptr == C_NULL)
            return error("Unable to read IFD:",i)
        end
        data = unsafe_load(content_ptr)
        res = unsafe_wrap(Array, data.entries, data.count)
        if data.count == 0
            continue
        end
        for i in 1:data.count
            if unsafe_load(res[i]).tag in tags
                str = Vector{Cuchar}(undef, 1024);
                LibExif.exif_entry_get_value(Ref(unsafe_load(res[i])), str, length(str))
                result[string(unsafe_load(res[i]).tag)] = rstrip(String(str), '\0')
                delete!(tags, unsafe_load(res[i]).tag)
            end
        end
    end
    return result
end

read_tags(filepath::AbstractString; kwargs...) = read_tags(read(filepath); kwargs...)
read_tags(io::IO; kwargs...) = read_tags(read(io); kwargs...)

end # module
