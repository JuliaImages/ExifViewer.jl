const FILE_BYTE_ORDER = LibExif.EXIF_BYTE_ORDER_INTEL

"""
    init_tag(exif, ifd, tag)

Initialize the entry of `tag` in `ifd` of `exif`.
"""
function init_tag(exif, ifd, tag)
    exif1 = unsafe_load(exif)
    entry = LibExif.exif_content_get_entry(exif1.ifd[ifd], tag)
    if entry == C_NULL
        entry = LibExif.exif_entry_new()
        entry.tag = tag
        LibExif.exif_content_add_entry(exif1.ifd[ifd], entry)
        LibExif.exif_entry_initialize(entry, tag)
        LibExif.exif_entry_unref(entry)
    end
    return entry
end

"""
    set_value(ptrentry, tagv)

Set the value of the entry pointed by `ptrentry` to `tagv`.
"""
function set_value(ptrentry, tagv)
    entry = unsafe_load(ptrentry)
    if entry.format == LibExif.EXIF_FORMAT_SHORT
        if entry.tag in keys(TagsDict)
            LibExif.exif_set_short(entry.data,LibExif.EXIF_BYTE_ORDER_INTEL, TagsDict[entry.tag][tagv])
        elseif (entry.tag == LibExif.EXIF_TAG_YCBCR_SUB_SAMPLING)
            val = split(tagv, ",")
            LibExif.exif_set_short(entry.data,LibExif.EXIF_BYTE_ORDER_INTEL, parse(Int, val[1]))
            LibExif.exif_set_short(entry.data + 4,LibExif.EXIF_BYTE_ORDER_INTEL, parse(Int, val[2]))
        else
            @info entry.tag tagv
            LibExif.exif_set_short(entry.data,LibExif.EXIF_BYTE_ORDER_INTEL, parse(Int, tagv))
        end
    elseif entry.format == LibExif.EXIF_FORMAT_LONG
        LibExif.exif_set_long(entry.data, FILE_BYTE_ORDER, parse(Cuint, tagv))
    elseif entry.format == LibExif.EXIF_FORMAT_RATIONAL
        if entry.tag in [LibExif.EXIF_TAG_FNUMBER, LibExif.EXIF_TAG_APERTURE_VALUE, LibExif.EXIF_TAG_MAX_APERTURE_VALUE]    
            p = Rational(parse(Float32, split(tagv, "/")[2]))
        else
            p = rationalize(parse(Float32, tagv);tol=0.1)
        end
        LibExif.exif_set_rational(entry.data,FILE_BYTE_ORDER, LibExif.ExifRational(p.num, p.den))
    elseif entry.format == LibExif.EXIF_FORMAT_ASCII
        len = sizeof(tagv)+1
        unsafe_store!(ptrentry.size, Cuint(len), 1)
        unsafe_store!(ptrentry.components, Culong(len), 1)
        mem = LibExif.exif_mem_new_default()
        buf = LibExif.exif_mem_alloc(mem, len)
        unsafe_copyto!(buf, pointer(Vector{UInt8}(tagv * "\0")), len)
        ptrentry.data = buf
    elseif entry.format == LibExif.EXIF_FORMAT_SRATIONAL
        p = Rational(parse(Float32, tagv))
        LibExif.exif_set_srational(entry.data, FILE_BYTE_ORDER, LibExif.ExifSRational(p.num, p.den))
    elseif entry.format == LibExif.EXIF_FORMAT_UNDEFINED
        if entry.tag == LibExif.EXIF_TAG_FLASH_PIX_VERSION
            data = Dict{String,String}(
            "FlashPix Version 1.0" => "0100\0",
            "FlashPix Version 1.01" => "0101\0",
            "Unknown FlashPix Version" => "0000\0",
            )
            unsafe_copyto!(entry.data, pointer(Vector{UInt8}(data[tagv])), 5)
        else
            @debug "Tag unsupported" entry.tag
        end
    else
        @debug "Tag unsupported" entry.tag
    end
end

"""
    create_exif_data(tags::Dict{String, String})

Create an exif data structure from a dictionary of tags.
"""
function create_exif_data(tags)
    exif = LibExif.exif_data_new()
    LibExif.exif_data_set_option(exif, LibExif.EXIF_DATA_OPTION_FOLLOW_SPECIFICATION)
    LibExif.exif_data_set_data_type(exif, LibExif.EXIF_DATA_TYPE_COMPRESSED)
    LibExif.exif_data_set_byte_order(exif, LibExif.EXIF_BYTE_ORDER_INTEL)
    LibExif.exif_data_fix(exif)
    inputs = keys(tags)

    for i in inputs
        key = normalize_exif_flag(i)
        x = LibExif.EXIF_DATA_TYPE_UNCOMPRESSED_CHUNKY

        # indentify which ifds tag goes in
        ifds = [
            LibExif.EXIF_IFD_0,
            LibExif.EXIF_IFD_1,
            LibExif.EXIF_IFD_EXIF,
            LibExif.EXIF_IFD_GPS,
            LibExif.EXIF_IFD_INTEROPERABILITY,
            LibExif.EXIF_IFD_COUNT,
        ]

        A = [LibExif.exif_tag_get_support_level_in_ifd(key, i, x) for i in ifds]
        ifd = findfirst(==(LibExif.EXIF_SUPPORT_LEVEL_MANDATORY), A)

        if ifd === nothing
            ifd = findfirst(==(LibExif.EXIF_SUPPORT_LEVEL_OPTIONAL), A)
        end

        if key == LibExif.EXIF_TAG_YCBCR_POSITIONING
            ifd = 1
        end
        if key in [LibExif.EXIF_TAG_PIXEL_X_DIMENSION, LibExif.EXIF_TAG_PIXEL_Y_DIMENSION]
            ifd = 3
        end
        
        if ifd === nothing
            @debug "Tag not supported currently or No Appropriate IFD found " key
            continue
        end

        entry = init_tag(exif, ifd, key)
        set_value(entry, tags[i])
    end
    return exif
end

"""
write_tags(filepath::AbstractString; img::AbstractArray, tags::Dict{String,Any})

Write EXIF tags to a filepath(currently support for jpeg and jpg available). 

### Keyword Arguments
- `filepath::AbstractString` : Name of the file to which image and exif is written.
- `img::AbstractArray` : Image Array whose exif data is being written to the filepath mentioned above.
- `tags::Dict{String,Any}` : EXIF tags and their corresponding values as defined in libexif library

### Examples

```jl
julia> using ExifViewer, TestImages
julia> img = testimage("mandrill")

julia> tags = Dict{String, Any}(
    "EXIF_TAG_MAKE"=>"Canon",
    "EXIF_TAG_ORIENTATION"=>"Top-left",
    "EXIF_TAG_X_RESOLUTION"=>"300",
    "EXIF_TAG_Y_RESOLUTION"=>"300",
)
julia> write_tags("test.jpg"; img, tags=tags)

julia> read_tags("test.jpg")
Dict{String, Any} with 10 entries:
  "EXIF_TAG_COLOR_SPACE"              => "Uncalibrated"
  "EXIF_TAG_COMPONENTS_CONFIGURATION" => "Y Cb Cr -"
  "EXIF_TAG_FLASH_PIX_VERSION"        => "FlashPix Version 1.0"
  "EXIF_TAG_Y_RESOLUTION"             => "300"
  "EXIF_TAG_ORIENTATION"              => "Top-left"
  "EXIF_TAG_EXIF_VERSION"             => "Exif Version 2.1"
  "EXIF_TAG_RESOLUTION_UNIT"          => "Inch"
  "EXIF_TAG_MAKE"                     => "Canon"
  "EXIF_TAG_YCBCR_POSITIONING"        => "Centered"
  "EXIF_TAG_X_RESOLUTION"             => "300"
```

Note: some tags are present by default like EXIF version, FLASHPIX version etc as can be seen in example above.
"""
function write_tags(filepath::AbstractString; img::AbstractArray, tags::Dict{String,String})
    # restricting filetype to .jpeg and .jpg
    if (!(splitext(filepath)[2] in (".jpeg", ".jpg")))
        throw(DomainError("Currently only jpeg and jpg files are supported for EXIF write operation."))
    end

    data = jpeg_encode(img)
    exif = create_exif_data(tags)
    exif_header = Vector{Cuchar}([0xff, 0xd8, 0xff, 0xe1])
    exif_data = Ref{Ptr{Cuchar}}()
    exif_data_len = Cuint(length(exif_data))
    ref_exif_data_len = Ref(exif_data_len)
    LibExif.exif_data_save_data(exif, exif_data, ref_exif_data_len)
    groups_vec = unsafe_wrap(Array, exif_data[], 5000)
    len = findfirst([0xff], groups_vec)[1]
    groups_vec = groups_vec[1:max(len, 1)]
    open(filepath, "w") do file
        write(file, exif_header) # done
        write(file, UInt8((len + 2) >> 8))
        write(file, UInt8((len + 2) & 0xff))
        write(file, groups_vec)
        write(file, data[3:end])
    end
end
