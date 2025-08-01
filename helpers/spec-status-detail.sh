#!/bin/bash
# Show detailed status of all specs using the configured spec path

# Get spec path from configuration
SPEC_PATH=$(spec-config)

# Check if spec path exists
if [ ! -d "$SPEC_PATH" ]; then
    echo "No specs directory found at: $SPEC_PATH"
    exit 0
fi

echo "Spec Status Report"
echo "=================="
echo "Path: $SPEC_PATH"
echo ""

# Find all directories that contain at least one .md file
for dir in "$SPEC_PATH"*/; do
    if [ -d "$dir" ]; then
        # Check if directory contains any .md files
        if ls "$dir"*.md >/dev/null 2>&1; then
            # Get just the directory name
            spec_name=$(basename "$dir")

            echo "$spec_name:"

            # Check plan status
            if [ -f "$dir/plan.md" ]; then
                plan_status=$(grep "^status:" "$dir/plan.md" 2>/dev/null | awk '{print $2}' | tr -d '"')
                echo "  - Plan: ${plan_status:-unknown}"
            else
                echo "  - Plan: not created"
            fi

            # Check requirements status
            if [ -f "$dir/requirements.md" ]; then
                req_status=$(grep "^status:" "$dir/requirements.md" 2>/dev/null | awk '{print $2}' | tr -d '"')
                echo "  - Requirements: ${req_status:-unknown}"
            else
                echo "  - Requirements: not created"
            fi

            # Check tasks progress
            if [ -f "$dir/tasks.md" ]; then
                total_tasks=$(grep -c "^- \[ \]" "$dir/tasks.md" 2>/dev/null)
                completed_tasks=$(grep -c "^- \[x\]" "$dir/tasks.md" 2>/dev/null)
                total=$((total_tasks + completed_tasks))
                if [ $total -gt 0 ]; then
                    echo "  - Tasks: $completed_tasks/$total completed"
                else
                    echo "  - Tasks: created (no checklist found)"
                fi
            else
                echo "  - Tasks: not created"
            fi

            echo ""
        fi
    fi
done

# If no specs found
if [ -z "$(ls -A "$SPEC_PATH" 2>/dev/null)" ]; then
    echo "No specs found"
fi