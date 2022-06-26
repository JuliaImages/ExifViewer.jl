@testset "exifviewer.jl" begin
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

    @testset "Different IFDs" begin
        @test length(read_metadata(filepath; allifds=true, ifds=1)) == 12
        @test length(read_metadata(filepath; allifds=true, ifds=10)) == 12 # this is a slightly weird behavior
        @test length(read_metadata(filepath; allifds=true, ifds=-1)) == 12 # same as above

        @test length(read_metadata(filepath; allifds=false, ifds=1:2)) == 7
        @test length(read_metadata(filepath; allifds=false, ifds=1:7)) == 12
        @test length(read_metadata(filepath; allifds=false, ifds=-1:10)) == 12

        @test length(read_metadata(filepath; allifds=false, ifds=(1,2))) == 7
        @test length(read_metadata(filepath; allifds=false, ifds=(1,7))) == 6
        @test length(read_metadata(filepath; allifds=false, ifds=(-1,10))) == 0

        # I didn't specify any ifds so it should return results from ifd 1 only
        @test length(read_tags(filepath; allifds=false, tags=[FLASH_PIX_VERSION, ORIENTATION])) == 1
        @test length(read_tags(filepath; allifds=false, tags=[FLASH_PIX_VERSION, ORIENTATION], ifds = 1)) == 1
        @test length(read_tags(filepath; allifds=false, tags=[FLASH_PIX_VERSION, ORIENTATION], ifds = 6)) == 0
        @test length(read_tags(filepath; allifds=false, tags=[FLASH_PIX_VERSION, ORIENTATION], ifds = -1)) == 0
        @test length(read_tags(filepath; allifds=false, tags=[FLASH_PIX_VERSION, ORIENTATION], ifds = 1:4)) == 2
        @test length(read_tags(filepath; allifds=false, tags=[FLASH_PIX_VERSION, ORIENTATION], ifds = 4:5)) == 0
        @test length(read_tags(filepath; allifds=false, tags=[FLASH_PIX_VERSION, ORIENTATION], ifds = (1,2,3))) == 2
        @test length(read_tags(filepath; allifds=false, tags=[FLASH_PIX_VERSION, ORIENTATION], ifds = (4,5))) == 0

        @test length(read_tags(filepath; allifds=true, tags=[FLASH_PIX_VERSION, ORIENTATION], ifds = 1)) == 2
        @test length(read_tags(filepath; allifds=true, tags=[FLASH_PIX_VERSION, ORIENTATION], ifds = (1,2,3))) == 2
        @test length(read_tags(filepath; allifds=true, tags=[FLASH_PIX_VERSION, ORIENTATION], ifds = 4:5)) == 2
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
