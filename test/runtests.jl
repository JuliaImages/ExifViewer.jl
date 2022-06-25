using ExifViewer
import ExifViewer.LibExif as LE
using Test, TestImages

filepath = testimage("earth_apollo17.jpg",download_only=true)

@testset "ExifViewer.jl" begin
    @testset "Basic IO" begin
        io = open(filepath, "r")
        @test read_metadata(io)["EXIF_TAG_PIXEL_X_DIMENSION"] == 3000
        
        @test read_metadata(filepath)["EXIF_TAG_EXIF_VERSION"] == "Exif Version 2.1"
        
        file = open(filepath, "r")
        @test read_metadata(file)["EXIF_TAG_ORIENTATION"] == "Top-left"

        io = open(filepath, "r")
        @test read_tags(io; tags=[EXIF_VERSION])["EXIF_TAG_EXIF_VERSION"] == "Exif Version 2.1"

        @test read_tags(filepath; tags=[EXIF_VERSION])["EXIF_TAG_EXIF_VERSION"] == "Exif Version 2.1"

        file = open(filepath, "r")
        @test read_tags(file; tags=[EXIF_VERSION])["EXIF_TAG_EXIF_VERSION"] == "Exif Version 2.1"
    end

    @testset "Thumbnail Data" begin
        ed_ptr = LE.exif_data_new_from_file(filepath)
        if (ed_ptr == C_NULL)
            return error("Unable to read EXIF data: invalid pointer")
        end
        ed = unsafe_load(ed_ptr)
        @test length(read_tags(filepath; tags=[ARTIST], extract_thumbnail=true)["EXIF_TAG_THUMBNAIL_DATA"]) == ed.size
        @test length(read_metadata(filepath; extract_thumbnail=true)["EXIF_TAG_THUMBNAIL_DATA"]) == ed.size
    end
end
