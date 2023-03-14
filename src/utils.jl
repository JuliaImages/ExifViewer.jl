
function numifds(ed::LibExif._ExifData)
    return length(ed.ifd)
end

function numentriesinifd(data::LibExif._ExifContent)
    return Int(data.count)
end

normalize_exif_flag(flags::Union{AbstractVector,Tuple}) = map(normalize_exif_flag, flags)
normalize_exif_flag(flag::AbstractString) = normalize_exif_flag(Symbol(flag))
normalize_exif_flag(flag::Symbol) = getfield(LibExif, flag)
normalize_exif_flag(flag::LibExif.ExifTag) = flag
normalize_exif_flag(flag::Int) = LibExif.ExifTag(flag)




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
    LibExif.EXIF_TAG_METERING_MODE => Dict{String,UInt64}(
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
    LibExif.EXIF_TAG_SENSING_METHOD => Dict{String,UInt64}(
        "Not defined" => 1,
        "One-chip color area sensor" => 2,
        "Two-chip color area sensor" => 3,
        "Three-chip color area sensor" => 4,
        "Color sequential area sensor" => 5,
        "Trilinear sensor" => 6,
        "Color sequential linear sensor" => 7,
        "" => 0,
    ),
    LibExif.EXIF_TAG_FLASH => Dict{String,UInt64}(
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
    LibExif.EXIF_TAG_YCBCR_POSITIONING => Dict{String,UInt64}("Centered" => 1, "Co-sited" => 2, "" => 0),
    LibExif.EXIF_TAG_RESOLUTION_UNIT => Dict{String,UInt64}(
        "Inch" => 2,
        "in" => 2,
        "Centimeter" => 3,
        "cm" => 3,
        "" => 0,
    ),
    LibExif.EXIF_TAG_FOCAL_PLANE_RESOLUTION_UNIT => Dict{String,UInt64}(
        "Inch" => 2,
        "in" => 2,
        "Centimeter" => 3,
        "cm" => 3,
    ),
    LibExif.EXIF_TAG_PLANAR_CONFIGURATION => Dict{String,UInt16}(
        "Chunky format" => 0,
        "Planar format" => 1,
    ),
    LibExif.EXIF_TAG_PHOTOMETRIC_INTERPRETATION => Dict{String,UInt16}(
        "Reversed mono" => 0,
        "Normal mono" => 1,
        "RGB" => 2,
        "Palette" => 3,
        "CMYK" => 5,
        "YCbCr" => 6,
        "CieLAB" => 8,
    ),
    LibExif.EXIF_TAG_CUSTOM_RENDERED => Dict{String,UInt16}(
        "Normal process" => 0,
        "Custom process" => 1,
    ),
    LibExif.EXIF_TAG_EXPOSURE_MODE => Dict{String,UInt16}(
        "Auto exposure" => 0,
        "Manual exposure" => 1,
        "Auto Bracket" => 2,
    ),
    LibExif.EXIF_TAG_WHITE_BALANCE => Dict{String,UInt16}(
        "Auto white balance" => 0,
        "Manual white balance" => 1,
    ),
    LibExif.EXIF_TAG_SCENE_CAPTURE_TYPE => Dict{String,UInt16}(
        "Standard" => 0,
        "Landscape" => 1,
        "Portrait" => 2,
        "Night scene" => 3,
    ),
    LibExif.EXIF_TAG_GAIN_CONTROL => Dict{String,UInt16}(
        "Normal" => 0,
        "Low gain up" => 1,
        "High gain up" => 2,
        "Low gain down" => 3,
        "High gain down" => 4,
    ),
    LibExif.EXIF_TAG_SATURATION => Dict{String,UInt16}(
        "Normal" => 0,
        "Low saturation" => 1,
        "High saturation" => 2
    ),
    LibExif.EXIF_TAG_CONTRAST => Dict{String,UInt16}(
        "Normal" => 0,
        "Soft" => 1,
        "Hard" => 2
    ),
    LibExif.EXIF_TAG_SHARPNESS => Dict{String,UInt16}(
        "Normal" => 0,
        "Soft" => 1,
        "Hard" => 2
    ),
)

