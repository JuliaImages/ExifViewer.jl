
function numifds(ed::LibExif._ExifData)
    return length(ed.ifd)
end

function numentriesinifd(data::LibExif._ExifContent)
    return Int(data.count)
end

normalize_exif_flag(flags::Union{AbstractVector, Tuple}) = map(normalize_exif_flag, flags)
normalize_exif_flag(flag::AbstractString) = normalize_exif_flag(Symbol(flag))
normalize_exif_flag(flag::Symbol) = getfield(LibExif, flag)
normalize_exif_flag(flag::LibExif.ExifTag) = flag
normalize_exif_flag(flag::Int) = LibExif.ExifTag(flag)