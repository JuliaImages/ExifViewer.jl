
function numifds(ed::LibExif._ExifData)
    return length(ed.ifd)
end

function numentriesinifd(data::LibExif._ExifContent)
    return Int(data.count)
end
