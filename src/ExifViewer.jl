module ExifViewer

include("../lib/LibExif.jl")
include("tags.jl")

using .LibExif

export read_metadata, read_tags

function numifds(ed::LibExif._ExifData)
    return length(ed.ifd)
end

function numentriesinifd(data::LibExif._ExifContent)
    return Int(data.count)
end

function fixformat(d, format)
    if (format == LibExif.EXIF_FORMAT_UNDEFINED || format == LibExif.EXIF_FORMAT_ASCII || format == LibExif.EXIF_FORMAT_SHORT || format == LibExif.EXIF_FORMAT_SSHORT)
        return d
    elseif (format == LibExif.EXIF_FORMAT_LONG || format == LibExif.EXIF_FORMAT_SLONG)
        d = parse(Int32, d)
    elseif (format == LibExif.EXIF_FORMAT_BYTE)
        d = parse(UInt8, d)
    elseif (format == LibExif.EXIF_FORMAT_SBYTE)
        d = parse(Int8, d)
    elseif (format == LibExif.EXIF_FORMAT_RATIONAL || format == LibExif.EXIF_FORMAT_SRATIONAL)
        d = parse(Int32, d)
    elseif (format == LibExif.EXIF_FORMAT_FLOAT || format == LibExif.EXIF_FORMAT_DOUBLE)
        d = parse(float, d)
    else
        error("Unknown format")
    end
    return d
end


"""
    read_metadata(data::Vector{UInt8}; kwargs...)
    read_metadata(filepath::AbstractString; kwargs...)
    read_metadata(io::IO; kwargs...)

Reads EXIF data from a filepath, IO, vector{Int8} and returns a Dict with tags and their values.

# Examples
```jldoctest
julia> using TestImages, ExifViewer
julia> filepath = testimage("earth_apollo17.jpg",download_only=true)

julia> io = open(filepath, "r")
julia> read_metadata(io)
Dict{Any, Any} with 12 entries:
  "EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
  "EXIF_TAG_ORIENTATION"       => "Top-left"
  "EXIF_TAG_EXIF_VERSION"      => "Exif Version 2.1\0ion"
  ⋮                            => ⋮

julia> read_metadata(filepath)
Dict{Any, Any} with 12 entries:
    "EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
    "EXIF_TAG_ORIENTATION"       => "Top-left"
    "EXIF_TAG_EXIF_VERSION"      => "Exif Version 2.1\0ion"
    ⋮                            => ⋮
  
julia> read_metadata(file)
Dict{Any, Any} with 12 entries:
      "EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
      "EXIF_TAG_ORIENTATION"       => "Top-left"
      "EXIF_TAG_EXIF_VERSION"      => "Exif Version 2.1\0ion"
      ⋮                            => ⋮
    
```
"""
function read_metadata(
    data::Vector{UInt8};
    allifds = true,
    ifds::Union{Int, NTuple, UnitRange} = 1,
    extract_thumbnail = false,
)
    ed_ptr = LibExif.exif_data_new_from_data(data, length(data))
    if (ed_ptr == C_NULL)
        return error("Unable to read EXIF data: invalid pointer")
    end
    ed = unsafe_load(ed_ptr)

    if (allifds == true)
        ifds = collect(1:numifds(ed))
    else
        ifds = collect(ifds)
        ifds = filter(x-> (x > 0 && x <= 5), ifds)
    end

    result = Dict{String,Any}()
    str = Vector{Cuchar}(undef, 1024)
    for i in ifds
        content_ptr = ed.ifd[i] # ques: do we need to unref these too?
        if (content_ptr == C_NULL)
            return error("Unable to read IFD:", i)
        end
        data = unsafe_load(content_ptr)
        if data.count == 0 continue end
        res = unsafe_wrap(Array, data.entries, data.count)
        for i = 1:data.count
            entry = unsafe_load(res[i])
            LibExif.exif_entry_get_value(Ref(entry), str, length(str))
            tag = String(copy(str))[1:findfirst(iszero, str)-1]
            tag = fixformat(tag, entry.format)
            if string(entry.tag) ∉ keys(result) result[string(entry.tag)] = tag end
        end
    end

    if (extract_thumbnail == true)
        thumbnail_size = Int(ed.size)
        thumbnail_data = unsafe_wrap(Array, ed.data, thumbnail_size)
        result["EXIF_TAG_THUMBNAIL_DATA"] = thumbnail_data
    end

    LibExif.exif_data_unref(ed_ptr)
    return result
end

read_metadata(filepath::AbstractString; kwargs...) = read_metadata(read(filepath); kwargs...)
read_metadata(io::IO; kwargs...) = read_metadata(read(io); kwargs...)

"""
    read_tags(data::Vector{UInt8}; tags::Vector{LibExif.ExifTag}
    read_tags(filepath::AbstractString; kwargs...)
    read_tags(io::IO; kwargs...)

Reads single or multiple tags from the EXIF data.

# Examples
```jldoctest
julia> using TestImages, ExifViewer
julia> filepath = testimage("earth_apollo17.jpg",download_only=true)
julia> io = open(filepath, "r")
julia> read_tags(io; tags=[LibExif.EXIF_TAG_FLASH_PIX_VERSION, LibExif.EXIF_TAG_ORIENTATION])
Dict{Any, Any} with 2 entries:
  "EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
  "EXIF_TAG_ORIENTATION"       => "Top-left"

julia> read_tags(filepath; tags=[LibExif.EXIF_TAG_FLASH_PIX_VERSION, LibExif.EXIF_TAG_ORIENTATION])
Dict{Any, Any} with 2 entries:
    "EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
    "EXIF_TAG_ORIENTATION"       => "Top-left"

julia> file = open(filepath, "r")
julia> read_tags(file, tags=[LibExif.EXIF_TAG_FLASH_PIX_VERSION, LibExif.EXIF_TAG_ORIENTATION])
Dict{Any, Any} with 2 entries:
      "EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
      "EXIF_TAG_ORIENTATION"       => "Top-left"
    
```
"""
function read_tags(
    data::Vector{UInt8};
    allifds = true,
    ifds::Union{Int,NTuple,UnitRange} = 1,
    tags::Vector{LibExif.ExifTag},
    extract_thumbnail = false,
)
    ed_ptr = LibExif.exif_data_new_from_data(data, length(data))

    if (ed_ptr == C_NULL)
        return error("Unable to read EXIF data: invalid pointer")
    end

    ed = unsafe_load(ed_ptr)

    if (allifds == true)
        ifds = collect(1:numifds(ed))
    else
        ifds = collect(ifds)
        ifds = filter(x-> (x > 0 && x <= 5), ifds)
    end
    
    result = Dict{String,Any}()
    tags = Set(tags)
    str = Vector{Cuchar}(undef, 1024)
    for i in ifds
        content_ptr = ed.ifd[i] # ques: do we need to unref these too?
        if (content_ptr == C_NULL)
            return error("Unable to read IFD:", i)
        end
        for i in tags
            entry = LibExif.exif_content_get_entry(content_ptr, i)
            if (entry == C_NULL) continue end
            entry = unsafe_load(entry)
            LibExif.exif_entry_get_value(Ref(entry), str, length(str))
            tag = String(copy(str))[1:findfirst(iszero, str)-1]
            tag = fixformat(tag, entry.format)
            if string(entry.tag) ∉ keys(result) result[string(entry.tag)] = tag end
            delete!(tags, entry.tag)
            if tags == Set() break end
        end
    end
    # not sure we should include this
    # if isempty(tags) != true
    #     @info "Non-Existent Tags:" tags
    # end

    if (extract_thumbnail == true)
        thumbnail_size = Int(ed.size)
        thumbnail_data = unsafe_wrap(Array, ed.data, thumbnail_size)
        result["EXIF_TAG_THUMBNAIL_DATA"] = thumbnail_data
    end

    LibExif.exif_data_free(ed_ptr)
    return result
end

read_tags(filepath::AbstractString; kwargs...) = read_tags(read(filepath); kwargs...)
read_tags(io::IO; kwargs...) = read_tags(read(io); kwargs...)

end # module
