using Clang.JLLEnvs
using Clang.Generators
using libexif_jll


include_dir = normpath(libexif_jll.artifact_dir, "include")

headers = [joinpath(include_dir, header) for header in readdir(include_dir) if endswith(header, ".h")]

options = load_options(joinpath(@__DIR__, "generator.toml"))

args =   get_default_args()
push!(args, "-I$include_dir")

# include <stdio.h> so that `size_t` and `FILE` are defined
system_dirs = map(x->x[9:end], filter(x->startswith(x, "-isystem"), args))
usrinclude_dir = system_dirs[findfirst(endswith("/usr/include"), system_dirs)]
header_stdio = joinpath(usrinclude_dir, "stdint.h")
push!(args, "-include$header_stdio")


ctx = create_context(headers, args, options)

build!(ctx)