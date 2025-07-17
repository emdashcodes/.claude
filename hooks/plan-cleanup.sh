#!/bin/bash
# Claude Hook Plan Cleanup and Approval Handler
# Handles plan approval and cleanup after exit_plan_mode completion

# Read all input
JSON_DATA=$(cat)

# Extract session_id and plan content
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null || echo "unknown-$(date +%s)")
SHORT_SESSION_ID=${SESSION_ID:0:8}

# Extract plan content for approved version
PLAN_CONTENT=$(echo "$JSON_DATA" | jq -r '.tool_input.plan' 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$PLAN_CONTENT" ] || [ "$PLAN_CONTENT" = "null" ]; then
    PLAN_CONTENT=$(echo "$JSON_DATA" | grep -o '"plan":"[^"]*"' | head -1 | sed 's/"plan":"//; s/"$//' | sed 's/\\n/\n/g; s/\\t/\t/g; s/\\"/"/g')
    
    if [ -z "$PLAN_CONTENT" ]; then
        PLAN_CONTENT=$(echo "$JSON_DATA" | sed -n 's/.*"plan":"\([^"]*\)".*/\1/p' | head -1 | sed 's/\\n/\n/g; s/\\t/\t/g; s/\\"/"/g')
    fi
fi

# Only create approved copy if we have valid plan content
if [ -n "$PLAN_CONTENT" ] && [ "$PLAN_CONTENT" != "# Plan Content Not Found" ]; then
    # Extract H1 title for filename
    H1_TITLE=$(echo -e "$PLAN_CONTENT" | grep -m1 '^# ' | sed 's/^# //' | head -1)
    if [ -z "$H1_TITLE" ]; then
        H1_TITLE="untitled-plan"
    fi

    # Create clean filename
    CLEAN_TITLE=$(echo "$H1_TITLE" | sed 's/[^a-zA-Z0-9 ]//g' | sed 's/ \+/ /g' | sed 's/^ \| $//g')
    if [ -z "$CLEAN_TITLE" ]; then
        CLEAN_TITLE="Untitled Plan"
    fi

    # Gather metadata for approved version
    CURRENT_DIR=$(pwd)
    TMUX_SESSION=""
    if [ -n "$TMUX" ]; then
        TMUX_SESSION=$(tmux display-message -p '#S' 2>/dev/null || echo "")
    fi
    CREATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%S%z")

    # Create frontmatter for approved version
    APPROVED_FRONTMATTER="---
session_id: \"$SESSION_ID\"
tmux_session: $(if [ -n "$TMUX_SESSION" ]; then echo "\"$TMUX_SESSION\""; else echo "null"; fi)
working_directory: \"$CURRENT_DIR\"
created_at: \"$CREATED_AT\"
status: \"approved\"
---
"

    # Create approved plans directory
    mkdir -p ~/Grimoire/Ada/Plans/Accepted

    # Create approved filename
    APPROVED_FILENAME="$CLEAN_TITLE ($SHORT_SESSION_ID).md"

    # Save approved plan
    echo -e "$APPROVED_FRONTMATTER$PLAN_CONTENT" > ~/Grimoire/Ada/Plans/Accepted/"$APPROVED_FILENAME"
    echo "Approved plan saved to ~/Grimoire/Ada/Plans/Accepted/$APPROVED_FILENAME"
fi

# Clean up ALL draft files for this session
CLEANED_COUNT=$(find ~/Grimoire/Ada/Plans -maxdepth 1 -name "* ($SHORT_SESSION_ID).md" -type f -delete -print | wc -l | tr -d ' ')

if [ "$CLEANED_COUNT" -gt 0 ]; then
    echo "Cleaned up $CLEANED_COUNT draft file(s) for session $SHORT_SESSION_ID"
else
    echo "No draft files found to clean up for session $SHORT_SESSION_ID"
fi