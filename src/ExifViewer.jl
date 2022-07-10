module ExifViewer

include("../lib/LibExif.jl")
include("utils.jl")
include("tags.jl")

using .LibExif
export read_metadata, read_tags

"""
    read_tags(data::Vector{UInt8}; tags::Vector{LibExif.ExifTag})
    read_tags(filepath::AbstractString; kwargs...)
    read_tags(io::IO; kwargs...)

    Read EXIF tags from the input source data. Return an empty dictionary if the source data doesn't contain EXIF tags.

# Examples
```jldoctest
julia> using TestImages, ExifViewer
julia> filepath = testimage("earth_apollo17.jpg",download_only=true)
julia> io = open(filepath, "r")
julia> read_tags(io; read_all=false, tags=[LibExif.EXIF_TAG_FLASH_PIX_VERSION, LibExif.EXIF_TAG_ORIENTATION])
Dict{Any, Any} with 2 entries:
  "EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
  "EXIF_TAG_ORIENTATION"       => "Top-left"

julia> read_tags(filepath; read_all=false, tags=[LibExif.EXIF_TAG_FLASH_PIX_VERSION, LibExif.EXIF_TAG_ORIENTATION])
Dict{Any, Any} with 2 entries:
    "EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
    "EXIF_TAG_ORIENTATION"       => "Top-left"

julia> file = open(filepath, "r")
julia> read_tags(file, read_all=false, tags=[LibExif.EXIF_TAG_FLASH_PIX_VERSION, LibExif.EXIF_TAG_ORIENTATION])
Dict{Any, Any} with 2 entries:
      "EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
      "EXIF_TAG_ORIENTATION"       => "Top-left"
    
```
"""
function read_tags(
    data::Vector{UInt8};
    ifds::Union{Int,NTuple,UnitRange} = 1:5,
    read_all = true,
    tags::Vector{LibExif.ExifTag} = Vector{LibExif.ExifTag}([]),
    extract_thumbnail = false,
    read_mnote = false
)
    ed_ptr = LibExif.exif_data_new_from_data(data, length(data))
    if (ed_ptr == C_NULL)
        return error("Unable to read EXIF data: invalid pointer")
    end
    result = Dict{String, Any}()
    try
        ed = unsafe_load(ed_ptr)
        ifds = collect(ifds)
        # ifds = read_all ? collect(1:numifds(ed)) : collect(ifds)
        checkbounds(Bool, collect(1:numifds(ed)), ifds) || throw(BoundsError(collect(1:numifds(ed)), ifds))
    
        tags = read_all ? tags : Set(tags)
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
                condition = read_all ? read_all : entry.tag in tags
                if condition
                    LibExif.exif_entry_get_value(Ref(entry), str, length(str))
                    tag = String(copy(str))[1:max(findfirst(iszero, str)-1, 1)] 
                    if string(entry.tag) ∉ keys(result)
                        result[string(entry.tag)] = tag
                    end
                end
                if read_all == false
                    delete!(tags, entry.tag)
                    if tags == Set() break end
                end
            end
        end

        # not sure we should include this
        # if isempty(tags) != true
        #     @info "Non-Existent Tags:" tags
        # end

        if (read_mnote == true)
            md_ptr = LibExif.exif_data_get_mnote_data(ed_ptr)
            if (md_ptr == C_NULL)
                return error("Unable to read MNOTE data")
            end
            try
                c = LibExif.exif_mnote_data_count(md_ptr)
                for i = 1:c
                    mnote = LibExif.exif_mnote_data_get_name(md_ptr, i)
                    if (mnote == C_NULL) continue end
                    data = unsafe_wrap(Array, mnote, 30)
                    data = Base.convert(Vector{UInt8}, data[1:max(findfirst(iszero, data)-1, 1)])
                    name = String(copy(data))
                    name = uppercase(replace(name, " "=>"_")) # preprocess
                    LibExif.exif_mnote_data_get_value(md_ptr, i, str, length(str))
                    tag = String(copy(str))[1:max(findfirst(iszero, str)-1, 1)]
                    if name ∉ keys(result)
                        result["MNOTE_" * name] = tag
                    end
                end
            finally
                LibExif.exif_mnote_data_unref(md_ptr)
            end
        end

        if (extract_thumbnail == true)
            thumbnail_size = Int(ed.size)
            thumbnail_data = unsafe_wrap(Array, ed.data, thumbnail_size)
            result["EXIF_TAG_THUMBNAIL_DATA"] = thumbnail_data
        end
    finally
        LibExif.exif_data_unref(ed_ptr)
    end

    return result
end

read_tags(filepath::AbstractString; kwargs...) = read_tags(read(filepath); kwargs...)
read_tags(io::IO; kwargs...) = read_tags(read(io); kwargs...)

end 
# module
