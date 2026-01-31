#!/bin/bash
# Build all .md files to PDF using pandoc

# check if pandoc is available, if not tell the user and stop

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building PDF..."
pandoc "$SOURCE" -o parameter_table.pdf --pdf-engine=pdflatex -V geometry:margin=1in

echo "Done!"
