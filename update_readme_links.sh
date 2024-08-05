#!/bin/bash

# Define the readme file
README="readme.md"

# Use sed to replace .md links with .html links in Markdown link format
sed -i 's/\(\[[^]]*\](\([^)]*\)\)\.md/\1.html/g' "$README"

echo "Updated links in '$README' from .md to .html"
