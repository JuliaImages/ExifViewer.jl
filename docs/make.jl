push!(LOAD_PATH,"../src/")
using ExifViewer
using Documenter

DocMeta.setdocmeta!(ExifViewer, :DocTestSetup, :(using ExifViewer); recursive=true)

makedocs(;
    modules=[ExifViewer],
    authors="Ashwani Rathee",
    repo="github.com/ashwani-rathee/ExifViewer.jl/blob/{commit}{path}#{line}",
    sitename="ExifViewer.jl",
    format=Documenter.HTML(;
        prettyurls=Base.get(ENV, "CI", "false") == "true",
        canonical="https://ashwani-rathee.github.io/ExifViewer.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ashwani-rathee/ExifViewer.jl",
    devbranch="main",
    push_preview = true
) 