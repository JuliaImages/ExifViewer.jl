module ExifViewer

include("../lib/LibExif.jl")
include("utils.jl")
include("tags.jl")

using .LibExif

export read_metadata, read_tags



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
    ifds::Union{Int,NTuple,UnitRange} = 1:5,
    read_all = false,
    tags::Vector = [],
    extract_thumbnail = false,
)
    ed_ptr = LibExif.exif_data_new_from_data(data, length(data))
    if (ed_ptr == C_NULL)
        return error("Unable to read EXIF data: invalid pointer")
    end

    ed = unsafe_load(ed_ptr)

    ifds = collect(ifds)
    checkbounds(Bool, collect(1:numifds(ed)), ifds) || throw(BoundsError(collect(1:numifds(ed)), ifds))
    # ifds = filter(x -> (x > 0 && x <= 5), ifds)

    @assert typeof(tags) == Vector{LibExif.ExifTag} || typeof(tags) == Vector{Any}
    tags = read_all ? tags : Set(tags)
    result = Dict{String,Any}()
    str = Vector{Cuchar}(undef, 1024)

    for i in ifds
        content_ptr = ed.ifd[i] # ques: do we need to unref these too?
        if (content_ptr == C_NULL)
            return error("Unable to read IFD:", i)
        end
        data = unsafe_load(content_ptr)
        if data.count == 0
            continue
        end
        res = unsafe_wrap(Array, data.entries, data.count)
        for i = 1:data.count
            entry = unsafe_load(res[i])
            condition = read_all ? read_all : entry.tag in tags
            if condition
                LibExif.exif_entry_get_value(Ref(entry), str, length(str))
                tag = String(copy(str))[1:findfirst(iszero, str)-1]
                tag = fixformat(tag, entry.format)
                if string(entry.tag) ∉ keys(result)
                    result[string(entry.tag)] = tag
                end
            end
            if read_all == false
                delete!(tags, entry.tag)
                if tags == Set()
                    break
                end
            end
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

    LibExif.exif_data_unref(ed_ptr)
    return result
end

read_tags(filepath::AbstractString; kwargs...) = read_tags(read(filepath); kwargs...)
read_tags(io::IO; kwargs...) = read_tags(read(io); kwargs...)

read_metadata(
    data::Vector{UInt8};
    ifds::Union{Int,NTuple,UnitRange} = 1:5,
    extract_thumbnail = false,
) = read_tags(data; read_all = true, extract_thumbnail = extract_thumbnail, ifds = ifds)
read_metadata(
    filepath::AbstractString;
    ifds::Union{Int,NTuple,UnitRange} = 1:5,
    extract_thumbnail = false,
) = read_tags(
    read(filepath);
    read_all = true,
    extract_thumbnail = extract_thumbnail,
    ifds = ifds,
)
read_metadata(io::IO; ifds::Union{Int,NTuple,UnitRange} = 1:5, extract_thumbnail = false) =
    read_tags(read(io); read_all = true, extract_thumbnail = extract_thumbnail, ifds = ifds)

end # module
