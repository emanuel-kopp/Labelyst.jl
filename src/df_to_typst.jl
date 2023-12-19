using DataFrames

function make_outfile(output_file)
    if occursin("/", output_file)
        dir = rsplit(output_file, "/", limit=2)[1]
        @assert isdir(dir) "Target directory is not existing! Please mkdir first."
    end

    out_typ = output_file * ".typ"

    if (isfile(out_typ)) == false
        makefile = `touch $out_typ`
        run(makefile)
    end

    return out_typ
end

function typtopdf(out_typ)
    compile_typst = `typst compile $out_typ`
    run(compile_typst)

    remove_typ = `rm $out_typ`
    run(remove_typ)
    out_pdf = chop(out_typ, head = 0, tail = 3) * "pdf"
    print("PDF with labels created at " * out_pdf)
end

function check_typst_papersize(papersize)
    supported_2023 = ["a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10", "a11", "iso-b1", "iso-b2", "iso-b3", "iso-b4", "iso-b5", "iso-b6", "iso-b7", "iso-b8", "iso-c3", "iso-c4", "iso-c5", "iso-c6", "iso-c7", "iso-c8", "din-d3", "din-d4", "din-d5", "din-d6", "din-d7", "din-d8", "sis-g5", "sis-e5", "ansi-a", "ansi-b", "ansi-c", "ansi-d", "ansi-e", "arch-a", "arch-b", "arch-c", "arch-d", "arch-e1", "arch-e", "jis-b0", "jis-b1", "jis-b2", "jis-b3", "jis-b4", "jis-b5", "jis-b6", "jis-b7", "jis-b8", "jis-b9", "jis-b10", "jis-b11", "sac-d0", "sac-d1", "sac-d2", "sac-d3", "sac-d4", "sac-d5", "sac-d6", "iso-id-1", "iso-id-2", "iso-id-3", "asia-f4", "jp-shiroku-ban-4", "jp-shiroku-ban-5", "jp-shiroku-ban-6", "jp-kiku-4", "jp-kiku-5", "jp-business-card", "cn-business-card", "eu-business-card", "fr-tellière", "fr-couronne-écriture", "fr-couronne-édition", "fr-raisin", "fr-carré", "fr-jésus", "uk-brief", "uk-draft", "uk-foolscap", "uk-quarto", "uk-crown", "uk-book-a", "uk-book-b", "us-letter", "us-legal", "us-tabloid", "us-executive", "us-foolscap-folio", "us-statement", "us-ledger", "us-oficio", "us-gov-letter", "us-gov-legal", "us-business-card", "us-digest", "us-trade", "newspaper-compact", "newspaper-berliner", "newspaper-broadsheet", "presentation-16-9", "presentation-4-3"]
    @assert papersize ∈ supported_2023 "Given paper size not accepted by Typst (state: Dec. 2023), find supported paper sizes at https://typst.app/docs/reference/layout/page/"
end

# Method 1: assumes one label per page
"""
    labelyst(dataframe, output_file; <keyword arguments>)

Take a `julia DataFrame` and produce a `.pdf` file with labels containing QR-codes and human readable codes.

...
### Keyword arguments
- `font_size::String`: sets the font size for all the text on the label, default is `"12pt"`
- `make_pdf::Bool`: define wether you want a `.pdf` as output or a raw `.typ` file, deault is `true`
"""
function labelyst(dataframe, output_file, paper_format::Vector{String}; font_size="12pt", make_pdf = true)

    pagw = paper_format[1]
    pagh = paper_format[2]

    out_typ = make_outfile(output_file)
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
            cell(height: 100%)[#align(horizon + center)[#qr-code("$ID")]],
            cell(height: 100%)[#align(horizon + center)[#rotate(270deg)[$ID]]],
            cell(height: 100%)[],
            cell(height: 100%, inset: 5%)[#align(horizon + left)[$label]],
            cell(height: 100%)[],
            )"""
        )
    end

    close(typ)

    if make_pdf == true
        typtopdf(out_typ)
    elseif make_pdf == false
        print("typ with labels created at " * out_typ)
    end
end

# Method 2: standard paper size (rectangle) and cols x rows
function labelyst(dataframe, output_file, paper_format::String, label_division::Vector{Int}; font_size="12pt", make_pdf = true)

    check_typst_papersize(paper_format)

    rows = label_division[1]
    cols = label_division[2]
    
    out_typ = make_outfile(output_file)
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
            columns: (1fr, 6fr, 2fr, 1fr, 10fr, 2fr),
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
    if make_pdf == true
        typtopdf(out_typ)
    elseif make_pdf == false
        print("typ with labels created at " * out_typ)
    end
end

# Method 3: custom paper size (rectangle) and cols x rows
function labelyst(dataframe, output_file, paper_format::Vector{String}, label_division::Vector{Int}; font_size="12pt", make_pdf = true)

    pagw = paper_format[1]
    pagh = paper_format[2]

    rows = label_division[1]
    cols = label_division[2]
    
    out_typ = make_outfile(output_file)
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
            columns: (1fr, 6fr, 2fr, 1fr, 10fr, 2fr),
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
    if make_pdf == true
        typtopdf(out_typ)
    elseif make_pdf == false
        print("typ with labels created at " * out_typ)
    end
end