# Labelyst

[![Build Status](https://github.com/emanuel-kopp/Labelyst.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emanuel-kopp/Labelyst.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Create labels containing QR-codes and human-readable codes for your experiments!

The package exports one function only, `labelyst()`, which takes a `Julia` DataFrame and some additional parameters as inputs translates it into a (Typst)[https://typst.app/] file which is then, if desired, compiled into a PDF. To work with `Labelyst.jl` you need Typst installed on your computer, learn about installation (here)[https://github.com/typst/typst].

# Examples
```julia-repl
testdf = DataFrame(
    ID = repeat(["p001", "p002"], 30),
    label = repeat(["label-1-test", "label-2-test"], 30))

labelyst(testdf, "test-labels", "a4", [10, 3])
```

<iframe width="100%" height="800" src="Output/klebeetiketten.pdf">

# Create labels to print on adhesive paper


# Create labels for pot experiments