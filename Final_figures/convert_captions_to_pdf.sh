#!/bin/bash
# Convert figure captions and supplementary tables from Markdown to PDF

# Check if pandoc is available
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is not installed or not in PATH"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the specific files to convert
FILES=(
    "Fig2_caption.md"
    "Supplementary_Table_1.md"
)

# Convert each .md file to PDF
cd "$SCRIPT_DIR"
for md_file in "${FILES[@]}"; do
    if [ -f "$md_file" ]; then
        pdf_file="${md_file%.md}.pdf"
        echo "Converting $md_file to $pdf_file..."
        pandoc "$md_file" -o "$pdf_file" --pdf-engine=pdflatex -V geometry:margin=0.75in
        if [ $? -eq 0 ]; then
            echo "  Success: $pdf_file created"
        else
            echo "  Error: Failed to convert $md_file"
        fi
    else
        echo "Warning: $md_file does not exist, skipping..."
    fi
done

echo "Done!"
