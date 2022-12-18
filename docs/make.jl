push!(LOAD_PATH,"../src/")
using ExifViewer
using Documenter

DocMeta.setdocmeta!(ExifViewer, :DocTestSetup, :(using ExifViewer); recursive=true)

makedocs(;
    modules=[ExifViewer],
    sitename="ExifViewer.jl",
)

deploydocs(;
    repo="github.com/JuliaImages/ExifViewer.jl",
)