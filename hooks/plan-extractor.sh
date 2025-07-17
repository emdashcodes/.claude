#!/bin/bash
# Claude Hook Plan Extractor
# Extracts plan content from exit_plan_mode hook JSON data
# Creates smart filenames and adds comprehensive metadata

# Create directory
mkdir -p ~/Grimoire/Ada/Plans

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

# Extract H1 title for filename
H1_TITLE=$(echo -e "$PLAN_CONTENT" | grep -m1 '^# ' | sed 's/^# //' | head -1)
if [ -z "$H1_TITLE" ]; then
    H1_TITLE="untitled-plan"
fi

# Create clean filename: remove special chars but preserve case and spaces
CLEAN_TITLE=$(echo "$H1_TITLE" | sed 's/[^a-zA-Z0-9 ]//g' | sed 's/ \+/ /g' | sed 's/^ \| $//g')
if [ -z "$CLEAN_TITLE" ]; then
    CLEAN_TITLE="Untitled Plan"
fi

# Gather metadata
CURRENT_DIR=$(pwd)
TMUX_SESSION=""
if [ -n "$TMUX" ]; then
    TMUX_SESSION=$(tmux display-message -p '#S' 2>/dev/null || echo "")
fi
CREATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%S%z")

# Create frontmatter
FRONTMATTER="---
session_id: \"$SESSION_ID\"
tmux_session: $(if [ -n "$TMUX_SESSION" ]; then echo "\"$TMUX_SESSION\""; else echo "null"; fi)
working_directory: \"$CURRENT_DIR\"
created_at: \"$CREATED_AT\"
status: \"draft\"
---
"

# Create filename
FILENAME="$CLEAN_TITLE ($SHORT_SESSION_ID).md"

# Save plan with frontmatter
echo -e "$FRONTMATTER$PLAN_CONTENT" > ~/Grimoire/Ada/Plans/"$FILENAME"
echo "Plan saved to ~/Grimoire/Ada/Plans/$FILENAME"