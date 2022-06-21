using ExifViewer
using Documenter

format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true"
)

makedocs(;
    modules=[ExifViewer],
    sitename="ExifViewer.jl",
    format=format,
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ashwani-rathee/ExifViewer.jl",
    devbranch="master",
)