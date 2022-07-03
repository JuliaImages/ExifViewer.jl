
function numifds(ed::LibExif._ExifData)
    return length(ed.ifd)
end

function numentriesinifd(data::LibExif._ExifContent)
    return Int(data.count)
end

function fixformat(d, format)
    if (
        format == LibExif.EXIF_FORMAT_UNDEFINED ||
        format == LibExif.EXIF_FORMAT_ASCII ||
        format == LibExif.EXIF_FORMAT_SHORT ||
        format == LibExif.EXIF_FORMAT_SSHORT
    )
        return d
    elseif (format == LibExif.EXIF_FORMAT_LONG || format == LibExif.EXIF_FORMAT_SLONG)
        d = parse(Int32, d)
    elseif (format == LibExif.EXIF_FORMAT_BYTE)
        d = parse(UInt8, d)
    elseif (format == LibExif.EXIF_FORMAT_SBYTE)
        d = parse(Int8, d)
    elseif (
        format == LibExif.EXIF_FORMAT_RATIONAL || format == LibExif.EXIF_FORMAT_SRATIONAL
    )
        d = parse(Int32, d)
    elseif (format == LibExif.EXIF_FORMAT_FLOAT || format == LibExif.EXIF_FORMAT_DOUBLE)
        d = parse(float, d)
    else
        error("Unknown format")
    end
    return d
end
