#!/bin/bash

# Check if help flag is provided
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Usage: $0 [-o output-path] <path-to-mscz-file>"
    echo "Exports a MuseScore file (.mscz) to PDF format"
    echo ""
    echo "Options:"
    echo "  -h, --help            Show this help message"
    echo "  -o, --output PATH     Specify custom output path for PDF"
    exit 0
fi

# Parse command line arguments
OUTPUT_PATH=""
while getopts "o:" opt; do
    case $opt in
        o) OUTPUT_PATH="$OPTARG";;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    esac
done
shift $((OPTIND-1))

# Check if an input file was provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 [-o output-path] <path-to-mscz-file>"
    exit 1
fi

# Store input file path and output PDF path
INPUT_FILE="$1"
if [ -n "$OUTPUT_PATH" ]; then
    OUTPUT_PDF="$OUTPUT_PATH"
else
    OUTPUT_PDF="${INPUT_FILE%.*}.pdf"
fi


if [ -z "$MSCORE_PATH" ]; then
    echo "Error: MSCORE_PATH environment variable is not set"
    exit 1
fi


# Generate PDF of score and parts
"$MSCORE_PATH" "$INPUT_FILE" -o "$OUTPUT_PDF" --export-score-parts 2>/dev/null

# Get score metadata and find out how many pages the score is
METADATA=$("$MSCORE_PATH" "$INPUT_FILE" --score-meta 2>/dev/null)
PAGES=$(echo "$METADATA" | grep -o '"pages":[[:space:]]*[0-9]*' | grep -o '[0-9]*')

# Reorder the pages in the PDF so the parts come before the score
if command -v qpdf >/dev/null 2>&1; then
    echo "Reordering pages in ${OUTPUT_PDF}"
    TEMP_PDF=$(mktemp)
    qpdf --empty --pages "$OUTPUT_PDF" $(($PAGES+1))-z "$OUTPUT_PDF" 1-$PAGES -- "$TEMP_PDF"
    mv "$TEMP_PDF" "$OUTPUT_PDF"
else
    echo "Warning: qpdf is not installed. The PDF parts will appear after the score."
fi

echo "Exported to ${OUTPUT_PDF}"