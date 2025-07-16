#!/bin/bash

# Check arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <pdf_file> <password> [-r]"
    exit 1
fi

PDF_FILE="$1"
PASSWORD="$2"
REMOVE_ORIGINAL="$3"

# Check if input file exists
if [ ! -f "$PDF_FILE" ]; then
    echo "Error: File '$PDF_FILE' not found."
    exit 1
fi

# Build output filename
DIR=$(dirname "$PDF_FILE")
FILENAME=$(basename "$PDF_FILE")
BASENAME="${FILENAME%.[Pp][Dd][Ff]}"
OUTPUT_FILE="$DIR/${BASENAME}.unlocked.pdf"

# Run qpdf (ignore exit status)
qpdf --password="$PASSWORD" --decrypt "$PDF_FILE" "$OUTPUT_FILE"

# Check if output file exists
if [ -f "$OUTPUT_FILE" ]; then
    echo "Password removed. Output saved to: $OUTPUT_FILE"

    if [ "$REMOVE_ORIGINAL" == "-r" ]; then
        rm -f "$PDF_FILE"
        echo "Original file removed: $PDF_FILE"
    fi
else
    echo "Failed to remove password. Output file was not created."
    exit 1
fi

