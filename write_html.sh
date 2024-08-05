#!/bin/bash

# Define the header file and the suffix
HEADER="global.header.html"
SUFFIX=".html"

# Ensure the header file exists
if [ ! -f "$HEADER" ]; then
    echo "Header file '$HEADER' not found!"
    exit 1
fi

# Process each content file matching the glob pattern
find posts -type f -name '*.md' | while read -r CONTENT; do
    if [ -f "$CONTENT" ]; then
        # Extract the base filename without the extension
        BASENAME=$(basename "$CONTENT" .md)
        DIRNAME=$(dirname "$CONTENT")
        
        # Define the output filename
        OUTPUT="${DIRNAME}/${BASENAME}${SUFFIX}"
        
        # Concatenate header and content to create the new file
        cat "$HEADER" "$CONTENT" > "$OUTPUT"
        
        echo "Created '$OUTPUT' with header and contents from '$CONTENT'"
    else
        echo "No matching content files found in 'contents' directory."
        exit 1
    fi
done

echo "All files processed successfully."