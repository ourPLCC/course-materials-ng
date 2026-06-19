#!/bin/bash

set -e

MARKDOWN_DIR="markdown"
OUTPUT_DIR="./temp/generate-pdfs/pdf_output"
PLANTUML_IMG_DIR="./temp/generate-pdfs/plantuml_images"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$PLANTUML_IMG_DIR"

for mdfile in "$MARKDOWN_DIR"/*.md; do
    base=$(basename "$mdfile" .md)
    tmp_md="./temp/generate-pdfs/tmp_${base}.md"
    cp "$mdfile" "$tmp_md"

    # Extract and render each PlantUML block
    awk -v base="$base" -v imgdir="$PLANTUML_IMG_DIR" '
    BEGIN { in_puml=0; count=0 }
    /^```plantuml/ { in_puml=1; count++; fname=sprintf("%s/%s-%d.puml", imgdir, base, count); print "" > fname; next }
    /^```/ && in_puml { in_puml=0; next }
    in_puml { print > fname }
    ' "$mdfile"

    # Render all .puml files to PNG using plantuml Docker
    for puml in "$PLANTUML_IMG_DIR"/${base}-*.puml; do
        [ -e "$puml" ] || continue
        docker run --rm -v "$(pwd)":/workspace plantuml/plantuml -tpng "/workspace/$puml"
    done

    # Replace all PlantUML blocks with their corresponding images in a single pass
    awk -v base="$base" -v imgdir="$PLANTUML_IMG_DIR" '
    BEGIN { inblock=0; count=0 }
    {
        if ($0 ~ /^```plantuml/) {
            inblock=1
            count++
            printf("![](%s/%s-%d.png)\n", imgdir, base, count)
            next
        }
        if (inblock && $0 ~ /^```/) {
            inblock=0
            next
        }
        if (!inblock) print $0
    }' "$tmp_md" > "${tmp_md}.new"
    mv "${tmp_md}.new" "$tmp_md"

    # Convert to PDF using pandoc Docker (with latex support)
    docker run --rm -v "$(pwd)":/data pandoc/latex \
        "/data/$tmp_md" -o "/data/$OUTPUT_DIR/$base.pdf"

    rm "$tmp_md"
done
