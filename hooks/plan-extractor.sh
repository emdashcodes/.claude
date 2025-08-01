#!/bin/bash
# Claude Hook: Plan Extractor
#
# PURPOSE:
#   Automatically captures and saves plan content when Claude's exit_plan_mode tool is used.
#   Creates draft plan files in the spec directory structure for integration with spec workflow.
#
# TRIGGERED BY:
#   Claude Code hook system when exit_plan_mode tool is called
#
# FUNCTIONALITY:
#   - Extracts plan content from Claude's exit_plan_mode hook JSON data
#   - Generates clean kebab-case slug using Claude Code SDK
#   - Creates spec folder structure with plan.md
#   - Adds minimal frontmatter (session_id, status)
#   - Integrates with spec workflow for requirements generation
#
# CONFIGURATION:
#   Uses spec.json hierarchy: project → global → default (.claude/specs/)
#
# OUTPUT:
#   Creates: {spec_path}/{slug}/plan.md



# Get spec path from configuration
SPEC_PATH=$(spec-config)

# Ensure spec path exists
mkdir -p "$SPEC_PATH"

# Read all input
JSON_DATA=$(cat)


# Extract session_id safely (with error handling)
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null || echo "unknown-$(date +%s)")
SHORT_SESSION_ID=${SESSION_ID:0:8}

# Extract plan content with multiple fallback methods
PLAN_CONTENT=$(echo "$JSON_DATA" | jq -r '.tool_input.plan' 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$PLAN_CONTENT" ] || [ "$PLAN_CONTENT" = "null" ]; then
    PLAN_CONTENT=$(echo "$JSON_DATA" | grep -o '"plan":"[^"]*"' | head -1 | sed 's/"plan":"//; s/"$//' | sed 's/\\n/\n/g; s/\\t/\t/g; s/\\"/"/g')
    
    if [ -z "$PLAN_CONTENT" ]; then
        PLAN_CONTENT=$(echo "$JSON_DATA" | sed -n 's/.*"plan":"\([^"]*\)".*/\1/p' | head -1 | sed 's/\\n/\n/g; s/\\t/\t/g; s/\\"/"/g')
    fi
fi

if [ -z "$PLAN_CONTENT" ]; then
    PLAN_CONTENT="# Plan Content Not Found\n\nThe plan content could not be extracted from the hook data."
fi

# Extract H1 title for slug generation
H1_TITLE=$(echo -e "$PLAN_CONTENT" | grep -m1 '^# ' | sed 's/^# //' | head -1)
if [ -z "$H1_TITLE" ]; then
    H1_TITLE="untitled-plan"
fi

# Get current directory name for context
CURRENT_DIR_NAME=$(basename "$(pwd)")

# Generate slug using Claude Code SDK with context
SLUG=$(claude -p "Convert this title to a kebab-case slug suitable for a folder name. Current project/directory is '$CURRENT_DIR_NAME' so avoid repeating that. Banned characters: # ^ [ ] |. Return ONLY the slug, nothing else: $H1_TITLE" 2>/dev/null)

# Fallback if Claude fails or returns something generic
if [ -z "$SLUG" ] || [ "$SLUG" = "null" ] || [ "$SLUG" = "untitled-plan" ] || [ ${#SLUG} -lt 3 ]; then
    SLUG=$(echo "$H1_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')

    # If manual generation also fails (no H1 or bad H1), use timestamp
    if [ -z "$SLUG" ] || [ "$SLUG" = "untitled-plan" ] || [ ${#SLUG} -lt 3 ]; then
        SLUG="plan-$(date +%Y%m%d-%H%M%S)"
        echo "[plan-extractor] Using timestamp slug: '$SLUG'" >> "$DEBUG_LOG"
    fi
fi

# Clean up banned characters just in case
SLUG=$(echo "$SLUG" | sed 's/[#^\[\]|]//g')

# Create minimal frontmatter
FRONTMATTER="---
session_id: \"$SESSION_ID\"
status: \"draft\"
---
"

# Clean up any existing spec directories for this session (in case plan name changed)
# Clean up any existing spec directories for this session
find "$SPEC_PATH" -maxdepth 2 -name "plan.md" -exec grep -l "session_id: \"$SESSION_ID\"" {} \; 2>/dev/null | while read plan_file; do
    old_dir=$(dirname "$plan_file")
    if [ "$old_dir" != "$SPEC_PATH$SLUG" ]; then
        rm -rf "$old_dir"
    fi
done

# Create spec folder
SPEC_FOLDER="$SPEC_PATH$SLUG"
mkdir -p "$SPEC_FOLDER"

# Save plan with frontmatter
echo -e "$FRONTMATTER$PLAN_CONTENT" > "$SPEC_FOLDER/plan.md"
echo "Plan saved to $SPEC_FOLDER/plan.md"
