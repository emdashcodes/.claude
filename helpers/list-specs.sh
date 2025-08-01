#!/bin/bash
# List available specs using the configured spec path from spec.json

# Get spec path from configuration
SPEC_PATH=$(spec-config)

# Check if spec path exists
if [ ! -d "$SPEC_PATH" ]; then
    echo "No specs directory found at: $SPEC_PATH"
    exit 0
fi

# List all spec directories
echo "Available specs in $SPEC_PATH:"
echo "================================"

# Find all directories that contain at least one .md file
for dir in "$SPEC_PATH"*/; do
    if [ -d "$dir" ]; then
        # Check if directory contains any .md files
        if ls "$dir"*.md >/dev/null 2>&1; then
            # Get just the directory name
            spec_name=$(basename "$dir")

            # Check what files exist
            files=""
            [ -f "$dir/plan.md" ] && files="${files}plan "
            [ -f "$dir/requirements.md" ] && files="${files}requirements "
            [ -f "$dir/tasks.md" ] && files="${files}tasks"

            # Output spec name with available files
            echo "- $spec_name (${files:-no files})"
        fi
    fi
done

# If no specs found
if [ -z "$(ls -A "$SPEC_PATH" 2>/dev/null)" ]; then
    echo "No specs found"
fi
