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

# Get score metadata
METADATA=$("$MSCORE_PATH" "$INPUT_FILE" --score-meta 2>/dev/null)

# Check MuseScore version
MSCORE_VERSION=$(echo "$METADATA" | grep -o '"mscoreVersion":[[:space:]]*"[^"]*"' | grep -o '[0-9][0-9.]*')
if [ -z "$MSCORE_VERSION" ]; then
    echo "Error: Could not determine MuseScore version from metadata"
    exit 1
fi

# Compare version with 4.0.0
if ! printf '%s\n' "$MSCORE_VERSION" "4.0.0" | sort -V | head -n1 | grep -q "^4\."; then
    echo "Error: This script requires that the score was created with MuseScore version 4.0.0 or greater (found version $MSCORE_VERSION)"
    exit 1
fi

# Count number of "instrumentId" occurrences, which appears exactly once per part
PART_COUNT=$(echo "$METADATA" | grep -o '"instrumentId":' | wc -l)

# Generate PDF of score and parts (if there is more than one part)
if [ "$PART_COUNT" -gt 1 ]; then
    "$MSCORE_PATH" "$INPUT_FILE" -o "$OUTPUT_PDF" --export-score-parts 2>/dev/null
else
    "$MSCORE_PATH" "$INPUT_FILE" -o "$OUTPUT_PDF" 2>/dev/null
    echo "------ Exported to ${OUTPUT_PDF}"
    exit 0
fi

# Get the number of pages in the score from metadata
PAGES=$(echo "$METADATA" | grep -o '"pages":[[:space:]]*[0-9]*' | grep -o '[0-9]*')

# Reorder the pages in the PDF so the parts come before the score
if command -v qpdf >/dev/null 2>&1; then
    echo "--- Reordering pages in ${OUTPUT_PDF}"
    TEMP_PDF=$(mktemp)
    qpdf --empty --pages "$OUTPUT_PDF" $(($PAGES+1))-z "$OUTPUT_PDF" 1-$PAGES -- "$TEMP_PDF"
    mv "$TEMP_PDF" "$OUTPUT_PDF"
else
    echo "Warning: qpdf is not installed. The PDF parts will appear after the score."
fi

echo "------ Exported to ${OUTPUT_PDF}"