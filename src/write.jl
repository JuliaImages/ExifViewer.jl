using ColorTypes
using JpegTurbo


const FILE_BYTE_ORDER = LibExif.EXIF_BYTE_ORDER_INTEL

function issupported(tag)
    if tag == "EXIF_TAG_MAKE" ||
       tag == "EXIF_TAG_ARTIST" ||
       tag == "EXIF_TAG_MODEL" ||
       tag == "EXIF_TAG_ORIENTATION" ||
       tag == "EXIF_TAG_X_RESOLUTION" ||
       tag == "EXIF_TAG_Y_RESOLUTION" ||
       tag == "EXIF_TAG_RESOLUTION_UNIT" ||
       tag == "EXIF_TAG_FOCAL_PLANE_RESOLUTION_UNIT" ||
       tag == "EXIF_TAG_YCBCR_POSITIONING" ||
       tag == "EXIF_TAG_COMPRESSION" ||
       tag == "EXIF_TAG_FNUMBER" ||
       tag == "EXIF_TAG_COMPRESSED_BITS_PER_PIXEL" ||
       tag == "EXIF_TAG_METERING_MODE" ||
       tag == "EXIF_TAG_FLASH" ||
       tag == "EXIF_TAG_FLASH_PIX_VERSION" ||
       tag == "EXIF_TAG_PIXEL_Y_DIMENSION" ||
       tag == "EXIF_TAG_PIXEL_X_DIMENSION" ||
       tag == "EXIF_TAG_IMAGE_WIDTH" ||
       tag == "EXIF_TAG_IMAGE_LENGTH" ||
       tag == "EXIF_TAG_COLOR_SPACE" ||
       tag == "EXIF_TAG_FOCAL_PLANE_X_RESOLUTION" ||
       tag == "EXIF_TAG_FOCAL_PLANE_Y_RESOLUTION" ||
       tag == "EXIF_TAG_SENSING_METHOD" ||
       tag == "EXIF_TAG_SUBJECT_DISTANCE_RANGE" ||
       tag == "EXIF_TAG_PLANAR_CONFIGURATION" ||
       tag == "EXIF_TAG_PHOTOMETRIC_INTERPRETATION" ||
       tag == "EXIF_TAG_CUSTOM_RENDERED" ||
       tag == "EXIF_TAG_EXPOSURE_MODE" ||
       tag == "EXIF_TAG_WHITE_BALANCE" ||
       tag == "EXIF_TAG_SCENE_CAPTURE_TYPE" ||
       tag == "EXIF_TAG_GAIN_CONTROL" ||
       tag == "EXIF_TAG_SATURATION" ||
       tag == "EXIF_TAG_SHARPNESS" ||
       tag == "EXIF_TAG_CONTRAST" 
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

TagsDict = Dict(
    LibExif.EXIF_TAG_COMPRESSION => Dict{String,UInt16}(
        "Uncompressed" => 1,
        "LZW compression" => 5,
        "JPEG compression" => 6,
        "Deflate/ZIP compression" => 8,
        "PackBits compression" => 32773,
        "" => 0,
    ),
    LibExif.EXIF_TAG_COLOR_SPACE => Dict{String,UInt16}(
        "sRGB" => 1,
        "Adobe RGB" => 2,
        "Uncalibrated" => 0xff,
        "" => 0,
    ),
    LibExif.EXIF_TAG_SUBJECT_DISTANCE_RANGE => Dict{String,UInt16}(
        "Unknown" => 0,
        "Macro" => 1,
        "Close view" => 2,
        "Distant view" => 3,
        "" => 0,
    ),
    LibExif.EXIF_TAG_ORIENTATION => Dict{String,UInt64}(
        "Top-left" => 1,
        "Top-right" => 2,
        "Bottom-right" => 3,
        "Bottom-left" => 4,
        "Left-top" => 5,
        "Right-top" => 6,
        "Right-bottom" => 7,
        "Left-bottom" => 8,
        "" => 0,
    ),
    LibExif.EXIF_TAG_METERING_MODE=>Dict{String,UInt64}(
        "Average" => 1,
        "Avg" => 1,
        "Center-weighted average" => 2,
        "Center-weight" => 2,
        "Spot" => 3,
        "Multi spot" => 4,
        "Pattern" => 5,
        "Partial" => 6,
        "Other" => 255,
        "" => 0,
    ),
    LibExif.EXIF_TAG_SENSING_METHOD=>Dict{String,UInt64}(
        "Not defined" => 1,
        "One-chip color area sensor" => 2,
        "Two-chip color area sensor" => 3,
        "Three-chip color area sensor" => 4,
        "Color sequential area sensor" => 5,
        "Trilinear sensor" => 6,
        "Color sequential linear sensor" => 7,
        "" => 0,
    ),
    LibExif.EXIF_TAG_FLASH=>Dict{String,UInt64}(
        "Flash did not fire" => 0x0000,
        "No flash" => 0x0000,
        "Flash fired" => 0x0001,
        "Flash" => 0x0001,
        "Yes" => 0x0001,
        "Strobe return light not detected" => 0x0005,
        "Without strobe" => 0x0005,
        "Strobe return light detected" => 0x0007,
        "With strobe" => 0x0007,
        "Flash did not fire" => 0x0007,
        "Flash fired, compulsory flash mode" => 0x0009,
        "Flash fired, compulsory flash mode, return light not detected" => 0x000d,
        "Flash fired, compulsory flash mode, return light detected" => 0x000f,
        "Flash did not fire, compulsory flash mode" => 0x0010,
        "Flash did not fire, auto mode" => 0x0018,
        "Flash fired, auto mode" => 0x0019,
        "Flash fired, auto mode, return light not detected" => 0x001d,
        "Flash fired, auto mode, return light detected" => 0x001f,
        "No flash function" => 0x0020,
        "Flash fired, red-eye reduction mode" => 0x0041,
        "Flash fired, red-eye reduction mode, return light not detected" => 0x0045,
        "Flash fired, red-eye reduction mode, return light detected" => 0x0047,
        "Flash fired, compulsory flash mode, red-eye reduction mode" => 0x0049,
        "Flash fired, compulsory flash mode, red-eye reduction mode, return light not detected" =>
            0x004d,
        "Flash fired, compulsory flash mode, red-eye reduction mode, return light detected" =>
            0x004f,
        "Flash did not fire, auto mode, red-eye reduction mode" => 0x0058,
        "Flash fired, auto mode, red-eye reduction mode" => 0x0059,
        "Flash fired, auto mode, return light not detected, red-eye reduction mode" =>
            0x005d,
        "Flash fired, auto mode, return light detected, red-eye reduction mode" =>
            0x005f,
        "" => 0,
    ),
    LibExif.EXIF_TAG_YCBCR_POSITIONING=>Dict{String,UInt64}("Centered" => 1, "Co-sited" => 2, "" => 0),
    LibExif.EXIF_TAG_RESOLUTION_UNIT=> Dict{String,UInt64}(
        "Inch" => 2,
        "in" => 2,
        "Centimeter" => 3,
        "cm" => 3,
        "" => 0,
        ),
    LibExif.EXIF_TAG_FOCAL_PLANE_RESOLUTION_UNIT=> Dict{String,UInt64}(
        "Inch" => 2,
        "in" => 2,
        "Centimeter" => 3,
        "cm" => 3,
        ),
    LibExif.EXIF_TAG_PLANAR_CONFIGURATION=>Dict{String,UInt16}(
        "Chunky format"=>0,
        "Planar format"=>1,
    ),
    LibExif.EXIF_TAG_PHOTOMETRIC_INTERPRETATION=>Dict{String, UInt16}(
        "Reversed mono"=>0,
        "Normal mono"=>1,
        "RGB"=>2,
        "Palette"=>3,
        "CMYK"=>5,
        "YCbCr"=>6,
        "CieLAB"=>8,
    ),
    LibExif.EXIF_TAG_CUSTOM_RENDERED=>Dict{String,UInt16}(
        "Normal process"=>0,
        "Custom process"=>1,
    ),
    LibExif.EXIF_TAG_EXPOSURE_MODE =>Dict{String, UInt16}(
        "Auto exposure"=>0,
        "Manual exposure"=>1,
        "Auto Bracket"=>2,
    ),
    LibExif.EXIF_TAG_WHITE_BALANCE =>Dict{String, UInt16}(
        "Auto white balance"=>0,
        "Manual white balance"=>1,
        ),
    LibExif.EXIF_TAG_SCENE_CAPTURE_TYPE =>Dict{String, UInt16}(
        "Standard"=>0,
        "Landscape"=>1,
        "Portrait"=>2,
        "Night scene"=>3,
        ),
    LibExif.EXIF_TAG_GAIN_CONTROL =>Dict{String, UInt16}(
        "Normal"=>0,
        "Low gain up"=>1,
        "High gain up"=>2,
        "Low gain down"=>3,
        "High gain down"=>4,
        ),
    LibExif.EXIF_TAG_SATURATION =>Dict{String, UInt16}(
        "Normal"=>0,
        "Low saturation"=>1,
        "High saturation"=>2
        ),
    LibExif.EXIF_TAG_CONTRAST =>Dict{String, UInt16}(
        "Normal"=>0,
        "Soft"=>1,
        "Hard"=>2
        ),
    LibExif.EXIF_TAG_SHARPNESS =>Dict{String, UInt16}(
        "Normal"=>0,
        "Soft"=>1,
        "Hard"=>2
        ),
)

function set_value(entry, tagv)
    if entry.tag in [
        LibExif.EXIF_TAG_COMPRESSION,
        LibExif.EXIF_TAG_COLOR_SPACE,
        LibExif.EXIF_TAG_SUBJECT_DISTANCE_RANGE,
        LibExif.EXIF_TAG_ORIENTATION,
        LibExif.EXIF_TAG_METERING_MODE,
        LibExif.EXIF_TAG_SENSING_METHOD,
        LibExif.EXIF_TAG_FLASH,
        LibExif.EXIF_TAG_YCBCR_POSITIONING,
        LibExif.EXIF_TAG_RESOLUTION_UNIT,
        LibExif.EXIF_TAG_FOCAL_PLANE_RESOLUTION_UNIT,
        LibExif.EXIF_TAG_PLANAR_CONFIGURATION,
        LibExif.EXIF_TAG_PHOTOMETRIC_INTERPRETATION,
        LibExif.EXIF_TAG_CUSTOM_RENDERED,
        LibExif.EXIF_TAG_EXPOSURE_MODE,
        LibExif.EXIF_TAG_WHITE_BALANCE,
        LibExif.EXIF_TAG_SCENE_CAPTURE_TYPE,
        LibExif.EXIF_TAG_GAIN_CONTROL,
        LibExif.EXIF_TAG_SATURATION,
        LibExif.EXIF_TAG_CONTRAST,
        LibExif.EXIF_TAG_SHARPNESS
    ]
        LibExif.exif_set_short(
            entry.data,
            LibExif.EXIF_BYTE_ORDER_INTEL,
            TagsDict[entry.tag][tagv],
        )
    elseif entry.tag == LibExif.EXIF_TAG_FLASH_PIX_VERSION
        data = Dict{String,String}(
            "FlashPix Version 1.0" => "0100\0",
            "FlashPix Version 1.01" => "0101\0",
            "Unknown FlashPix Version" => "0000\0",
        )
        unsafe_copyto!(entry.data, pointer(Vector{UInt8}(data[tagv])), 5)
    elseif (entry.tag in [LibExif.EXIF_TAG_MAKE, LibExif.EXIF_TAG_ARTIST, LibExif.EXIF_TAG_MODEL])
        unsafe_copyto!(entry.data, pointer(Vector{UInt8}(tagv * "\0")), length(tagv) + 1)
    elseif entry.tag in [
        LibExif.EXIF_TAG_PIXEL_Y_DIMENSION,
        LibExif.EXIF_TAG_PIXEL_X_DIMENSION,
        LibExif.EXIF_TAG_X_RESOLUTION,
        LibExif.EXIF_TAG_Y_RESOLUTION,
        LibExif.EXIF_TAG_IMAGE_WIDTH,
        LibExif.EXIF_TAG_IMAGE_LENGTH,
    ]
        LibExif.exif_set_long(entry.data, FILE_BYTE_ORDER, parse(Cuint, tagv))
    elseif entry.tag in [
        LibExif.EXIF_TAG_EXPOSURE_TIME,
        LibExif.EXIF_TAG_COMPRESSED_BITS_PER_PIXEL,
        LibExif.EXIF_TAG_APERTURE_VALUE,
        LibExif.EXIF_TAG_MAX_APERTURE_VALUE,
        LibExif.EXIF_TAG_FOCAL_LENGTH,
        LibExif.EXIF_TAG_FOCAL_PLANE_X_RESOLUTION,
        LibExif.EXIF_TAG_FOCAL_PLANE_Y_RESOLUTION,
    ]
        p = rationalize(parse(Float32, tagv);tol=0.1)
        LibExif.exif_set_rational(entry.data,FILE_BYTE_ORDER, LibExif.ExifRational(p.num, p.den))
    elseif entry.tag in [LibExif.EXIF_TAG_SHUTTER_SPEED_VALUE, LibExif.EXIF_TAG_EXPOSURE_BIAS_VALUE]
        p = Rational(parse(Float32, tagv))
        LibExif.exif_set_srational(entry.data, FILE_BYTE_ORDER, LibExif.ExifSRational(p.num, p.den))
    elseif entry.tag == LibExif.EXIF_TAG_FNUMBER
        p = Rational(parse(Float32, split(tagv, "/")[2]))
        LibExif.exif_set_rational(entry.data, FILE_BYTE_ORDER, LibExif.ExifRational(p.num, p.den))
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

    for i in keys1
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

        if ifd === nothing || issupported(i) == false
            @debug "Tag not supported currently or No Appropriate IFD found " key
            continue
        end

        entry1 = init_tag(exif, ifd, key)
        entry = unsafe_load(entry1)
        set_value(entry, tags[i])
    end
    return exif
end

function write_tags(filepath::AbstractString; img::AbstractArray, tags::Dict{String,Any})
    data = jpeg_encode(img)
    exif1 = create_exif_data(tags)
    # return exif1
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
