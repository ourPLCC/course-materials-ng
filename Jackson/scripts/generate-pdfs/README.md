## generate-pdfs.bash

## Here is a Bash script that will:

1. Find all PlantUML code blocks in each markdown file in markdown.
2. Render each PlantUML block to a PNG image using the plantuml/plantuml Docker container.
3. Replace each PlantUML code block in the markdown with an image reference to the generated PNG.
4. Use a pandoc Docker container to convert the modified markdown to PDF.
5. Output the PDF in the same directory as the markdown file.

## How it works:

* For each markdown file, it extracts PlantUML blocks, renders them to PNG, and replaces the blocks with image links.
* Uses Docker containers for both PlantUML and Pandoc.
* Outputs PDFs to pdf_output/.

## Usage:

You may need to adjust image paths in the markdown if you want them relative to the PDF or move the images as needed.

```bash
./generate-pdfs.bash
```
