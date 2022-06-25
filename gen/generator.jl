using Clang.JLLEnvs
using Clang.Generators
using libexif_jll

include_dir = normpath(libexif_jll.artifact_dir, "include")
prefix = "/libexif/"
headers = [
    joinpath(include_dir * prefix, header) for
    header in readdir(include_dir * prefix) if endswith(header, ".h")
]
options = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir")
push!(args, "--include=stdint.h")

ctx = create_context(headers, args, options)

build!(ctx)