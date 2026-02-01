#!/bin/bash
# Build all .md files to PDF using pandoc

# Check if pandoc is available, if not tell the user and stop
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is not installed or not in PATH"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the folders to process
FOLDERS=(
    "EquationsParametersDocs"
    "RandomMatrixTheoryDocs"
    "StabilityAnalysisDocs"
)

# FOLDERS=(
#     "EquationsParametersDocs"
# )

# Convert each .md file to PDF in each folder
for folder in "${FOLDERS[@]}"; do
    folder_path="$SCRIPT_DIR/$folder"
    if [ -d "$folder_path" ]; then
        echo "Processing folder: $folder"
        cd "$folder_path"
        for md_file in *.md; do
            if [ -f "$md_file" ]; then
                pdf_file="${md_file%.md}.pdf"
                echo "  Converting $md_file to $pdf_file..."
                pandoc "$md_file" -o "$pdf_file" --pdf-engine=pdflatex -V geometry:margin=0.75in
            fi
        done
    else
        echo "Warning: Folder $folder does not exist, skipping..."
    fi
done

# Convert the root README.md separately
README_PATH="$SCRIPT_DIR/../README.md"
if [ -f "$README_PATH" ]; then
    echo "Converting root README.md to PDF..."
    pandoc "$README_PATH" -o "$SCRIPT_DIR/../README.pdf" --pdf-engine=pdflatex -V geometry:margin=0.75in
fi

echo "Done!"
