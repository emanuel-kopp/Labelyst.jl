using DataFrames

function labelyst(dataframe, output_file; myh = "17mm", myw = "90mm", scale_factor = "0.2", font_size = "12pt")
    
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
        #set page(width: $myw, height: $myh, margin: 1mm)
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
            cell(height: 100%)[#align(horizon + center)[#qr-code("$ID", height: $myh - $myh*$scale_factor, width: $myh - $myh*$scale_factor)]],
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