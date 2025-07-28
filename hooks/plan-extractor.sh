#!/bin/bash
# Claude Hook: Spec-Aware Plan Extractor
#
# PURPOSE:
#   Captures plan content when Claude's exit_plan_mode tool is used and creates
#   a spec folder structure with the plan as the initial spec document.
#
# TRIGGERED BY:
#   Claude Code hook system when exit_plan_mode tool is called
#
# FUNCTIONALITY:
#   - Extracts plan content from Claude's exit_plan_mode hook JSON data
#   - Generates slug from plan title using AdaScript
#   - Creates spec folder structure in configured location
#   - Saves plan.md with session metadata
#   - Initiates spec workflow for requirements generation
#
# CONFIGURATION:
#   Requires spec.json with specs_path configured
#   Falls back to .claude/specs in project root if not specified
#
# OUTPUT:
#   Creates: [specs_path]/{slug}/plan.md

# Read all input
JSON_DATA=$(cat)

# Extract session_id safely
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null || echo "unknown-$(date +%s)")

# Extract plan content with multiple fallback methods
PLAN_CONTENT=$(echo "$JSON_DATA" | jq -r '.tool_input.plan' 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$PLAN_CONTENT" ] || [ "$PLAN_CONTENT" = "null" ]; then
    PLAN_CONTENT=$(echo "$JSON_DATA" | grep -o '"plan":"[^"]*"' | head -1 | sed 's/"plan":"//; s/"$//' | sed 's/\\n/\n/g; s/\\t/\t/g; s/\\"/"/g')
    
    if [ -z "$PLAN_CONTENT" ]; then
        PLAN_CONTENT=$(echo "$JSON_DATA" | sed -n 's/.*"plan":"\([^"]*\)".*/\1/p' | head -1 | sed 's/\\n/\n/g; s/\\t/\t/g; s/\\"/"/g')
    fi
fi

if [ -z "$PLAN_CONTENT" ]; then
    echo "Error: Could not extract plan content from hook data" >&2
    exit 1
fi

# Extract H1 title for slug generation
H1_TITLE=$(echo -e "$PLAN_CONTENT" | grep -m1 '^# ' | sed 's/^# //' | head -1)
if [ -z "$H1_TITLE" ]; then
    H1_TITLE="untitled-plan"
fi

# Generate slug using AdaScript if available, otherwise create simple slug
if command -v ada >/dev/null 2>&1; then
    SLUG=$(echo "$H1_TITLE" | ada harvest slug 2>/dev/null || echo "")
fi

# Fallback slug generation if AdaScript fails or is not available
if [ -z "$SLUG" ]; then
    SLUG=$(echo "$H1_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')
fi

if [ -z "$SLUG" ]; then
    SLUG="spec-$(date +%s)"
fi

# Get specs path from spec.json configuration or use default
SPEC_CONFIG="/Users/emdash/.claude/spec.json"
if [ -f "$SPEC_CONFIG" ]; then
    SPECS_PATH=$(cat "$SPEC_CONFIG" | jq -r '.specs_path' 2>/dev/null)
    if [ "$SPECS_PATH" = "null" ] || [ -z "$SPECS_PATH" ]; then
        SPECS_PATH=".claude/specs"
    fi
else
    SPECS_PATH=".claude/specs"
fi

# If specs_path is relative, make it relative to current working directory
if [[ ! "$SPECS_PATH" = /* ]]; then
    SPECS_PATH="$(pwd)/$SPECS_PATH"
fi

# Create spec directory structure
SPEC_DIR="$SPECS_PATH/$SLUG"
mkdir -p "$SPEC_DIR"

# Create frontmatter for plan.md
CREATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%S%z")
FRONTMATTER="---
session_id: $SESSION_ID
status: draft
created_at: $CREATED_AT
---

"

# Save plan.md (ensuring we don't add extra line breaks)
echo -n "$FRONTMATTER" > "$SPEC_DIR/plan.md"
echo -e "$PLAN_CONTENT" >> "$SPEC_DIR/plan.md"

echo "Spec plan saved to $SPEC_DIR/plan.md"
echo "Spec workflow initiated for feature: $SLUG"

# Store the spec directory in a temporary file for plan-cleanup.sh to use
echo "$SPEC_DIR" > "/tmp/claude-spec-dir-$SESSION_ID"