#!/bin/bash
# Build parameter_table.md to PDF and DOCX

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SOURCE="parameter_table.md"
TEMPLATE="FrontierWordTemplate.docx"

echo "Building PDF..."
pandoc "$SOURCE" -o parameter_table.pdf --pdf-engine=pdflatex -V geometry:margin=1in

echo "Building DOCX..."
pandoc "$SOURCE" -o parameter_table.docx --reference-doc="$TEMPLATE"

echo "Done!"
