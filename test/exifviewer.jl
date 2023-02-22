@testset "exifviewer.jl" begin

    @testset "Basic IO" begin
        open(filepath, "r") do io
            @test read_tags(io; read_all=true)["EXIF_TAG_PIXEL_X_DIMENSION"] == "3000"
        end

        io = IOBuffer()
        try 
            write(io, read(filepath))
            @test read_tags(take!(io); read_all=true)["EXIF_TAG_PIXEL_X_DIMENSION"] == "3000"
        finally
            close(io)
        end

        @test read_tags(filepath; read_all=true)["EXIF_TAG_EXIF_VERSION"] == "Exif Version 2.1"

        open(filepath, "r") do file
            @test read_tags(file; read_all=true)["EXIF_TAG_ORIENTATION"] == "Top-left"
        end

        open(filepath, "r") do io
            @test read_tags(io; tags = ["EXIF_TAG_EXIF_VERSION"])["EXIF_TAG_EXIF_VERSION"] == "Exif Version 2.1"
        end 

        @test read_tags(filepath; tags = ["EXIF_TAG_EXIF_VERSION"])["EXIF_TAG_EXIF_VERSION"] == "Exif Version 2.1"

        open(filepath, "r") do io
            @test read_tags(io; tags = ["EXIF_TAG_EXIF_VERSION"])["EXIF_TAG_EXIF_VERSION"] == "Exif Version 2.1"
        end

        @test typeof(read_tags([0x00, 0x01])) == Dict{String, Any} # to see behavior when garbage data in
    end

    @testset "Different IFDs" begin
        @test length(read_tags(filepath; read_all=true, ifds = 1)) == 6
        @test length(read_tags(filepath; read_all=true, ifds = 1:2)) == 7
        @test length(read_tags(filepath; read_all=true, ifds = (1, 2))) == 7

        @test length(read_tags(filepath; read_all=false, tags = ["EXIF_TAG_FLASH_PIX_VERSION", "EXIF_TAG_ORIENTATION"])) == 2
        @test length(read_tags(filepath; read_all=false, tags = ["EXIF_TAG_FLASH_PIX_VERSION", "EXIF_TAG_ORIENTATION"], ifds = 1),) == 1
        @test length(read_tags(filepath; read_all=false, tags = ["EXIF_TAG_FLASH_PIX_VERSION", "EXIF_TAG_ORIENTATION"], ifds = 1:4),) == 2
        @test length(read_tags(filepath; read_all=false, tags = ["EXIF_TAG_FLASH_PIX_VERSION", "EXIF_TAG_ORIENTATION"], ifds = 4:5),) == 0
        @test length(read_tags(filepath; read_all=false, tags = ["EXIF_TAG_FLASH_PIX_VERSION", "EXIF_TAG_ORIENTATION"], ifds = (1, 2, 3)),) == 2
        @test length(read_tags(filepath; read_all=false, tags = ["EXIF_TAG_FLASH_PIX_VERSION", "EXIF_TAG_ORIENTATION"], ifds = (4, 5)),) == 0
        @test length(read_tags(filepath; read_all=false, tags = ["EXIF_TAG_FLASH_PIX_VERSION", "EXIF_TAG_ORIENTATION"], ifds = 1)) == 1
        @test length(read_tags(filepath; read_all=false, tags = ["EXIF_TAG_FLASH_PIX_VERSION", "EXIF_TAG_ORIENTATION"], ifds = (1, 2, 3))) == 2

        # all wrongs
        @test_throws BoundsError read_tags(filepath; read_all=true, ifds = 6)
        @test_throws BoundsError read_tags(filepath; read_all=true, ifds = 6:7)
        @test_throws BoundsError read_tags(filepath; read_all=true, ifds = (6, 7, 8))

        # some right some wrongs
        @test_throws BoundsError read_tags(filepath; read_all=true, ifds = -1)
        @test_throws BoundsError read_tags(filepath; read_all=true, ifds = -1:6)
        @test_throws BoundsError read_tags(filepath; read_all=true, ifds = (-1, 2, 3))

        @test_throws BoundsError read_tags(filepath; ifds = 6)
        @test_throws BoundsError read_tags(filepath; ifds = 6:7)
        @test_throws BoundsError read_tags(filepath; ifds = (6, 7, 8))

        @test_throws BoundsError read_tags(filepath; ifds = -1)
        @test_throws BoundsError read_tags(filepath; ifds = -1:6)
        @test_throws BoundsError read_tags(filepath; ifds = (-1, 2, 3))
    end

    @testset "Thumbnail Data" begin
        ed_ptr = LE.exif_data_new_from_file(filepath)
        if (ed_ptr == C_NULL)
            return error("Unable to read EXIF data: invalid pointer")
        end
        ed = unsafe_load(ed_ptr)
        @test length(
            read_tags(filepath; tags = ["EXIF_TAG_ARTIST"], extract_thumbnail = true)["EXIF_TAG_THUMBNAIL_DATA"],
        ) == ed.size
        @test length(
            read_tags(filepath; read_all=true, extract_thumbnail = true)["EXIF_TAG_THUMBNAIL_DATA"],
        ) == ed.size
    end

    @testset "Mnote Data" begin
        @test length(read_tags(get_example("canon", 1); read_mnote=true)) == 115
        @test length(read_tags(get_example("fuji",1); read_mnote=true)) == 68

        @test length(read_tags(get_example("olympus", 2); read_mnote=true)) == 67
        @test length(read_tags(get_example("olympus", 3); read_mnote=true)) == 53
        @test length(read_tags(get_example("olympus", 4); read_mnote=true)) == 48
        @test length(read_tags(get_example("olympus", 5); read_mnote=true)) == 73

        @test length(read_tags(get_example("pentax", 2); read_mnote=true)) == 58
        @test length(read_tags(get_example("pentax", 3); read_mnote=true)) == 77
        @test length(read_tags(get_example("pentax", 4); read_mnote=true)) == 63
    end
end
