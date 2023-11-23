using DataFrames

"""
    labelyst(dataframe, output_file)

Takes a `julia DataFrame` and produces a `.pdf` file with labels containing QR-codes and human readable codes.
"""
function labelyst(dataframe, output_file, paper_format::Vector{String} = ["90mm", "17mm"]; label_format=["90mm", "17mm"], scale_factor="0.2", font_size="12pt")

    pagw = paper_format[1]
    pagh = paper_format[2]
    labw = label_format[1]
    labh = label_format[2]
    
    if occursin("/", output_file)
        dir = rsplit(output_file, "/", limit=2)[1]
        @assert isdir(dir) "Target directory is not existing! Please mkdir first."
    end

    out_typ = output_file * ".typ"

    if (isfile(out_typ)) == false
        makefile = `touch $out_typ`
        run(makefile)
    end

    typ = open(out_typ, "w")

    write(typ,
        """// import package to make QR codes
        #import "@preview/cades:0.2.0": qr-code

        // Set page layout
        #set page(height: $pagh, width: $pagw, margin: 1mm)
        #set text($font_size)

        #let cell = rect.with(
          inset: 3pt,
          width: 100%,
          height: 100%,
          radius: 2pt,
          stroke: none
        )

        """)

    for i in 1:nrow(dataframe)
        foo = dataframe[i, :]
        ID = foo.ID
        label = foo.label
        write(typ,
            """
            #grid(
            columns: (1fr, 3fr, 1fr, 1fr, 10fr, 4fr),
            cell(height: 100%)[],
            cell(height: 100%)[#align(horizon + center)[#qr-code("$ID", height: $labh - $labh*$scale_factor, width: $labh - $labh*$scale_factor)]],
            cell(height: 100%)[#align(horizon + center)[#rotate(270deg)[$ID]]],
            cell(height: 100%)[],
            cell(height: 100%, inset: 5%)[#align(horizon + left)[$label]],
            cell(height: 100%)[],
            )"""
        )
    end

    close(typ)

    compile_typst = `typst compile $out_typ`
    run(compile_typst)

    remove_typ = `rm $out_typ`
    run(remove_typ)
    out_pdf = output_file * ".pdf"
    print("PDF with labels created at " * out_pdf)
end

function labelyst(dataframe, output_file, paper_format::String = "a4", label_division::Vector{Int}=[10, 3]; scale_factor="0.2", font_size="12pt")

    rows = label_division[1]
    cols = label_division[2]
    
    if occursin("/", output_file)
        dir = rsplit(output_file, "/", limit=2)[1]
        @assert isdir(dir) "Target directory is not existing! Please mkdir first."
    end

    out_typ = output_file * ".typ"

    if (isfile(out_typ)) == false
        makefile = `touch $out_typ`
        run(makefile)
    end

    typ = open(out_typ, "w")

    write(typ,
        """// import package to make QR codes
        #import "@preview/cades:0.2.0": qr-code

        // Set page layout
        #set page(paper: "$paper_format", margin: 1mm)
        #set text($font_size)

        #let cell = rect.with(
          inset: 3pt,
          width: 100%,
          height: 100%,
          radius: 2pt,
          stroke: none
        )

        #grid(
            columns: ($cols),
            rows: ($rows),

        """)

    for i in 1:nrow(dataframe)
        foo = dataframe[i, :]
        ID = foo.ID
        label = foo.label
        write(typ,
            """
            grid(
            columns: (1fr, 3fr, 1fr, 1fr, 10fr, 4fr),
            cell(height: 100%/$rows)[],
            cell(height: 100%/$rows)[#align(horizon + center)[#qr-code("$ID")]],
            cell(height: 100%/$rows)[#align(horizon + center)[#rotate(270deg)[$ID]]],
            cell(height: 100%/$rows)[],
            cell(height: 100%/$rows, inset: 5%)[#align(horizon + left)[$label]],
            cell(height: 100%/$rows)[],
            ),
            """
        )
    end

    write(typ, ")")

    close(typ)

    compile_typst = `typst compile $out_typ`
    run(compile_typst)

    #remove_typ = `rm $out_typ`
    #run(remove_typ)
    out_pdf = output_file * ".pdf"
    print("PDF with labels created at " * out_pdf)
end