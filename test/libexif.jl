@testset "libexif.jl" begin
    @testset "Types check" begin
        data_ptr = LE.exif_data_new_from_file(filepath)
        @test typeof(data_ptr) == Ptr{LE._ExifData}
        @test data_ptr != C_NULL
        data = unsafe_load(data_ptr)
        @test typeof(data) === LE._ExifData
        @test typeof(data.ifd) == NTuple{5, Ptr{LE._ExifContent}}
    end
end