#!/bin/bash
# Quick YAML cleaner - one-liner version
# Usage: ./scripts/quick-yaml-clean.sh [file]

if [ $# -eq 1 ]; then
    # Clean specific file
    file="$1"
    echo "Cleaning $file..."
    
    # Remove trailing whitespace and basic redundant quotes
    sed -i -e 's/[[:space:]]*$//' -e 's/^\([[:space:]]*[a-zA-Z_-]*:[[:space:]]*\)"\([a-zA-Z0-9._/-]*\)"$/\1\2/' "$file"
    
    # Check results
    if grep -q '[[:space:]]$' "$file"; then
        echo "⚠️  Still has trailing whitespace"
    else
        echo "✅ Trailing whitespace cleaned"
    fi
else
    # Clean all YAML files
    echo "Quick cleaning all YAML files..."
    find . -name "*.yml" -o -name "*.yaml" | grep -v node_modules | grep -v .git | while read -r file; do
        echo "Processing $file"
        sed -i -e 's/[[:space:]]*$//' -e 's/^\([[:space:]]*[a-zA-Z_-]*:[[:space:]]*\)"\([a-zA-Z0-9._/-]*\)"$/\1\2/' "$file"
    done
    echo "✅ Quick clean completed!"
fi