using Documenter
using Labelyst

makedocs(
    sitename = "Labelyst",
    format = Documenter.HTML(),
    modules = [Labelyst],
    pages=[
        "Home" => "index.md"
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(;
    repo="github.com/emanuel-kopp/Labelyst.jl"
)
