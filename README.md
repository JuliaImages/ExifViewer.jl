

![](https://i.imgur.com/cvFnyt4.png)

<p style="text-align: center;">
ExifViewer.jl is a Julia wrapper of the C library libexif that provides EXIF support. EXIF is short for Exchangeable Image File, a format that is a standard for storing interchange information in digital photography image files using JPEG compression. 
</p>

[![Docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ashwani-rathee.github.io/ExifViewer.jl) [![Slack](https://img.shields.io/badge/chat-slack-e01e5a)](https://join.slack.com/t/julialang/shared_invite/zt-1hxxb5ryp-Ts_egJ7FRN2muQ7nkTtCNQ) [![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT) [![Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/ExifViewer)](https://pkgs.genieframework.com?packages=ExifViewer)
### Installation
--- 
If you have not yet installed Julia, please follow the [instructions](https://julialang.org/downloads/platform/) for your operating system. 

Stable Version
```julia
# Enter ']' from the REPL to enter Pkg mode.
pkg> add ExifViewer
```

Dev Version
```julia
using Pkg
# Enter ']' from the REPL to enter Pkg mode.
pkg> add https://github.com/ashwani-rathee/ExifViewer.jl.git
```

### Usage

ExifViewer.jl provides method to read EXIF tags from images using `read_tags` methods which can
take input in form of Filepath, IO, and bytes sequence(`Vector{UInt8}`)

`read_tags` reads EXIF tags from the input source data and it returns an empty 
dictionary if the source data doesn't contain EXIF tags.
There are couple of keyword arguments that are used by `read_tags` which have been
described below:

#### Keyword Arguments
- `ifds::Union{Int,NTuple,UnitRange}` : Defines which IFD(Image file directory) to search in for the EXIF tags. Default is all ifds i.e. 1:5.
- `read_all::Bool` : Defines if all EXIF tags are to be read or not. By default, `read_all` is true.
- `tags::Vector{LibExif.ExifTag}` : Defines which tags to search, in case `read_all` is false. When `read_all` is false, tags that need to be searched need to defined manually. Tags can be provided using bunch of methods but its suggested to supply a vector of strings with each string representing a EXIF tag i.e. ["`EXIF_TAG_FLASH_PIX_VERSION`", "`EXIF_TAG_ORIENTATION`"] 

- `extract_thumbnail::Bool` : Defines whether to read the thumbnail data or not. By default, `extract_thumbnail` is false.
- `read_mnote::Bool` : Defines whether to read the mnote(MakerNote) tags data or not. By default, `read_mnote` is false.

List of all available tags to search is available here: https://libexif.github.io/internals/exif-tag_8h.html

#### Examples
```jldoctest
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

Method to write exif data to files is also provided using `write_tags` and it writes EXIF tags to a 
filepath(currently support for jpeg and jpg available). 

#### Keyword Arguments
- `filepath::AbstractString` : Name of the file to which image and exif is written.
- `img::AbstractArray` : Image Array whose exif data is being written to the filepath mentioned above.
- `tags::Dict{String,Any}` : EXIF tags and their corresponding values as defined in libexif library

#### Examples

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

Note: Some tags are present by default like EXIF version, FLASHPIX version etc as can be seen in example above.


### Contributions and Issues:

If you have questions about ExifViewer.jl, feel free to get in touch via Slack or open an issue :hearts: