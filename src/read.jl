
const IFDS_ALL_FIELDS = 1:5 # Specifies all IFDs(Image File Directory)

"""
read_tags(data::Vector{UInt8}; kwargs...})
read_tags(filepath::AbstractString; kwargs...)
read_tags(io::IO; kwargs...)

Read EXIF tags from the input source data. Return an empty dictionary if the source data doesn't contain EXIF tags.

#### Keyword Arguments
- `ifds::Union{Int,NTuple,UnitRange}` : Defines which IFD(Image file directory) to search in for the EXIF tags. Default is all ifds i.e. 1:5.
- `read_all::Bool` : Defines if all EXIF tags are to be read or not. By default, `read_all` is true.
- `tags::Vector{LibExif.ExifTag}` : Defines which tags to search, in case `read_all` is false. When `read_all` is false, tags that need to be searched need to defined manually. Tags can be provided using bunch of methods but its suggested to supply a vector of strings with each string representing a EXIF tag i.e. ["`EXIF_TAG_FLASH_PIX_VERSION`", "`EXIF_TAG_ORIENTATION`"] 

- `extract_thumbnail::Bool` : Defines whether to read the thumbnail data or not. By default, `extract_thumbnail` is false.
- `read_mnote::Bool` : Defines whether to read the mnote(MakerNote) tags data or not. By default, `read_mnote` is false.

List of all available tags to search is available here: https://libexif.github.io/internals/exif-tag_8h.html

#### Examples
```jl
julia> using TestImages, ExifViewer
julia> filepath = testimage("earth_apollo17.jpg", download_only=true)
julia> io = open(filepath, "r")
julia> read_tags(io; read_all=false, tags=["EXIF_TAG_FLASH_PIX_VERSION", "EXIF_TAG_ORIENTATION"])
Dict{Any, Any} with 2 entries:
"EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
"EXIF_TAG_ORIENTATION"       => "Top-left"

julia> read_tags(filepath; read_all=false, tags=["EXIF_TAG_FLASH_PIX_VERSION", "EXIF_TAG_ORIENTATION"])
Dict{Any, Any} with 2 entries:
"EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
"EXIF_TAG_ORIENTATION"       => "Top-left"

julia> data = read(filepath)
julia> read_tags(data, read_all=false, tags=["EXIF_TAG_FLASH_PIX_VERSION", "EXIF_TAG_ORIENTATION"])
Dict{Any, Any} with 2 entries:
  "EXIF_TAG_FLASH_PIX_VERSION" => "FlashPix Version 1.0"
  "EXIF_TAG_ORIENTATION"       => "Top-left"

```
"""
function read_tags(
    data::Vector{UInt8};
    ifds::Union{Int,NTuple,UnitRange} = IFDS_ALL_FIELDS,
    read_all = true,
    tags::Union{AbstractVector,Tuple} = Vector{LibExif.ExifTag}([]),
    extract_thumbnail = false,
    read_mnote = false,
)
    ed_ptr = LibExif.exif_data_new_from_data(data, length(data))
    if (ed_ptr == C_NULL)
        return error("Unable to read EXIF data: invalid pointer")
    end

    tags = normalize_exif_flag(tags)
    typeassert(tags, Vector{LibExif.ExifTag})

    result = Dict{String,Any}()
    try
        ed = unsafe_load(ed_ptr)
        ifds = collect(ifds)
        # ifds = read_all ? collect(1:numifds(ed)) : collect(ifds)
        checkbounds(Bool, collect(1:numifds(ed)), ifds) ||
            throw(BoundsError(collect(1:numifds(ed)), ifds))

        tags = read_all ? tags : Set(tags)
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
            for j = 1:data.count
                entry = unsafe_load(res[j])
                # if(i == 4 & entry.tag in [0,1,2,50341,37520]) exif_tag_gps_set(entry) end
                condition = read_all ? read_all : entry.tag in tags
                if condition
                    LibExif.exif_entry_get_value(Ref(entry), str, length(str))
                    tag = String(copy(str))[1:max(findfirst(iszero, str) - 1, 1)]
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

        if (read_mnote == true)
            md_ptr = LibExif.exif_data_get_mnote_data(ed_ptr)
            if (md_ptr == C_NULL)
                return error("Unable to read MNOTE data")
            end
            LibExif.exif_mnote_data_ref(md_ptr)
            LibExif.exif_mnote_data_unref(md_ptr)
            c = LibExif.exif_mnote_data_count(md_ptr)
            for i = 0:c-1
                mnote = LibExif.exif_mnote_data_get_name(md_ptr, i)
                if (mnote == C_NULL)
                    continue
                end
                data = unsafe_string(mnote)
                name = uppercase(replace(data, " " => "_")) # preprocess
                LibExif.exif_mnote_data_get_value(md_ptr, i, str, length(str))
                tag = String(copy(str))[1:max(findfirst(iszero, str) - 1, 1)]
                if name ∉ keys(result)
                    result["MNOTE_"*name] = tag
                end
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

function read_tags(filepath::AbstractString; kwargs...)
    open(filepath, "r") do io
        read_tags(io; kwargs...)
    end
end

function read_tags(io::IO; kwargs...)
    try
        read_tags(read(io); kwargs...)
    finally
        close(io)
    end
end
