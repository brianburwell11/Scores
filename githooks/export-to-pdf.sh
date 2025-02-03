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

"$MSCORE_PATH" "$INPUT_FILE" -o "$OUTPUT_PDF" --export-score-parts 2>/dev/null

echo "Exported to ${OUTPUT_PDF}"