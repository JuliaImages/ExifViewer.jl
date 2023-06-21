@testset "write-exif.jl" begin
    img = testimage("mandrill")

    tags = Dict{String, String}(
        "EXIF_TAG_MAKE"=>"Canon",
        "EXIF_TAG_ARTIST"=>"Ashwani",
        "EXIF_TAG_MODEL"=>"R70",
        "EXIF_TAG_ORIENTATION"=>"Top-left",
        "EXIF_TAG_X_RESOLUTION"=>"300",
        "EXIF_TAG_Y_RESOLUTION"=>"300",
        "EXIF_TAG_RESOLUTION_UNIT"=>"Centimeter",
        "EXIF_TAG_FOCAL_PLANE_RESOLUTION_UNIT"=>"Inch",
        "EXIF_TAG_YCBCR_POSITIONING"=>"Co-sited",
        "EXIF_TAG_COMPRESSION"=>"JPEG compression",
        "EXIF_TAG_FNUMBER"=>"f/2.8",
        "EXIF_TAG_EXIF_VERSION"=> "Exif Version 2.1",
        "EXIF_TAG_METERING_MODE"=>"Pattern",
        "EXIF_TAG_FLASH"=>"Flash fired",
        "EXIF_TAG_FLASH_PIX_VERSION"=> "FlashPix Version 1.0",
        "EXIF_TAG_COLOR_SPACE"=>"sRGB",
        "EXIF_TAG_PIXEL_Y_DIMENSION"=>"2",
        "EXIF_TAG_PIXEL_X_DIMENSION"=>"2",
        "EXIF_TAG_FOCAL_PLANE_X_RESOLUTION"=>"4.5",
        "EXIF_TAG_FOCAL_PLANE_Y_RESOLUTION"=>"4.5",
        "EXIF_TAG_SENSING_METHOD"=>"One-chip color area sensor",
        "EXIF_TAG_SUBJECT_DISTANCE_RANGE"=>"Close view",
        "EXIF_TAG_PLANAR_CONFIGURATION"=>"Planar format",
        "EXIF_TAG_PHOTOMETRIC_INTERPRETATION"=>"CieLAB",
        "EXIF_TAG_CUSTOM_RENDERED"=>"Normal process",
        "EXIF_TAG_EXPOSURE_MODE"=>"Auto exposure",
        "EXIF_TAG_WHITE_BALANCE"=>"Auto white balance",
        "EXIF_TAG_SCENE_CAPTURE_TYPE"=>"Standard",
        "EXIF_TAG_GAIN_CONTROL"=>"Normal",
        "EXIF_TAG_SATURATION"=>"Normal",
        "EXIF_TAG_CONTRAST"=>"Normal",
        "EXIF_TAG_SHARPNESS"=>"Normal",
        "EXIF_TAG_COMPONENTS_CONFIGURATION"=> "Y Cb Cr -"
    )
    path = joinpath(tempdir(), "tmp.jpg")
    write_tags(path; img, tags)
    # currently only .jpg supported, different value of these were already checked
    # case where key in dict is not found needs to be handled,
    # support level issue needs to be handled
    @test read_tags(path) == tags
    rm(path)
end