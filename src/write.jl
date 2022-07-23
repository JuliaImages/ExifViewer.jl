using ColorTypes
using JpegTurbo


const FILE_BYTE_ORDER = LibExif.EXIF_BYTE_ORDER_INTEL

function issupported(tag)
    if tag == "EXIF_TAG_COMPRESSION" ||
       tag == "EXIF_TAG_FLASH_PIX_VERSION" ||
       tag == "EXIF_TAG_PIXEL_Y_DIMENSION" ||
       tag == "EXIF_TAG_PIXEL_X_DIMENSION" ||
       tag == "EXIF_TAG_X_RESOLUTION" ||
       tag == "EXIF_TAG_Y_RESOLUTION"
        return true
    else
        return false
    end
end

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

function set_value(entry, tagv)
    if entry.tag == LibExif.EXIF_TAG_COMPRESSION
        data = Dict{String,UInt64}(
            "Uncompressed" => 1,
            "LZW compression" => 5,
            "JPEG compression" => 6,
            "Deflate/ZIP compression" => 8,
            "PackBits compression" => 32773,
            "" => 0,
        )
        LibExif.exif_set_short(
            entry.data,
            LibExif.EXIF_BYTE_ORDER_INTEL,
            convert(UInt16, data[tagv]),
        )
    elseif entry.tag == LibExif.EXIF_TAG_FLASH_PIX_VERSION
        data = Dict{String,String}(
            "FlashPix Version 1.0" => "0100\0",
            "FlashPix Version 1.01" => "0101\0",
            "Unknown FlashPix Version" => "0000\0",
        )
        unsafe_copyto!(entry.data, pointer(Vector{UInt8}(data[tagv])), 5)
    elseif entry.tag == LibExif.EXIF_TAG_PIXEL_Y_DIMENSION ||
           entry.tag == LibExif.EXIF_TAG_PIXEL_X_DIMENSION ||
           entry.tag == LibExif.EXIF_TAG_X_RESOLUTION ||
           entry.tag == LibExif.EXIF_TAG_Y_RESOLUTION
        LibExif.exif_set_long(entry.data, FILE_BYTE_ORDER, parse(Cuint, tagv))
    else
        println("Tag Not Supported")
    end
end

function create_exif_data(tags)
    exif = LibExif.exif_data_new()
    LibExif.exif_data_set_option(exif, LibExif.EXIF_DATA_OPTION_FOLLOW_SPECIFICATION)
    LibExif.exif_data_set_data_type(exif, LibExif.EXIF_DATA_TYPE_COMPRESSED)
    LibExif.exif_data_set_byte_order(exif, LibExif.EXIF_BYTE_ORDER_INTEL)
    LibExif.exif_data_fix(exif)

    keys1 = keys(tags)
    values1 = values(tags)
    for i in keys1
        # println("Tag: " * i)
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

        if ifd === nothing || issupported(i) == false
            @info "Tag not supported currently or No Appropriate IFD found " key
            continue
        end
        entry1 = init_tag(exif, ifd, key)
        entry = unsafe_load(entry1)
        # println(entry.format)
        set_value(entry, tags[i])
    end
    return exif
end

function write_tags(filepath::AbstractString; img::AbstractArray, tags::Dict{String,Any})
    data = jpeg_encode(img)
    exif1 = create_exif_data(tags)
    exif_header = Vector{Cuchar}([0xff, 0xd8, 0xff, 0xe1])
    exif_data = Ref{Ptr{Cuchar}}()
    exif_data_len = Cuint(length(exif_data))
    ref_exif_data_len = Ref(exif_data_len)
    LibExif.exif_data_save_data(exif1, exif_data, ref_exif_data_len)
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
