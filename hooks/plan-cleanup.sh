#!/bin/bash
# Claude Hook: Plan Cleanup and Approval Handler
#
# PURPOSE:
#   Handles the final stage of plan workflow - approval and cleanup after user confirms a plan.
#   Converts draft plans to approved status and removes temporary draft files.
#
# TRIGGERED BY:
#   Claude Code hook system after user approves a plan from exit_plan_mode
#   Typically runs after plan-extractor.sh has created the initial draft
#
# FUNCTIONALITY:
#   - Extracts approved plan content from hook JSON data
#   - Creates approved version in /Accepted subdirectory with "approved" status
#   - Cleans up all draft plan files for the session to prevent clutter
#   - Maintains same filename format but moves to organized approval structure
#
# WORKFLOW:
#   1. plan-extractor.sh creates draft plan when exit_plan_mode is called
#   2. User reviews and approves plan
#   3. plan-cleanup.sh creates approved copy and cleans up drafts
#
# CONFIGURATION:
#   Requires vault.json with plans_path configured
#   Example: {"plans_path": "~/Vault/Plans"}
#
# OUTPUT:
#   - Approved plans in: [plans_path]/Accepted/
#   - Removes draft files from: [plans_path]/

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

    # Get plans path from vault configuration
    PLANS_PATH=$(cat ~/.claude/vault.json | jq -r '.plans_path')
    PLANS_PATH=$(eval echo "$PLANS_PATH")  # Expand ~ and other variables

    # Create approved plans directory
    mkdir -p "$PLANS_PATH/Accepted"

    # Create approved filename
    APPROVED_FILENAME="$CLEAN_TITLE ($SHORT_SESSION_ID).md"

    # Save approved plan
    echo -e "$APPROVED_FRONTMATTER$PLAN_CONTENT" > "$PLANS_PATH/Accepted/$APPROVED_FILENAME"
    echo "Approved plan saved to $PLANS_PATH/Accepted/$APPROVED_FILENAME"
fi

# Get plans path for cleanup (use same logic as above, but outside the if block)
PLANS_PATH=$(cat ~/.claude/vault.json | jq -r '.plans_path')
PLANS_PATH=$(eval echo "$PLANS_PATH")  # Expand ~ and other variables

# Clean up ALL draft files for this session
CLEANED_COUNT=$(find "$PLANS_PATH" -maxdepth 1 -name "* ($SHORT_SESSION_ID).md" -type f -delete -print | wc -l | tr -d ' ')

if [ "$CLEANED_COUNT" -gt 0 ]; then
    echo "Cleaned up $CLEANED_COUNT draft file(s) for session $SHORT_SESSION_ID"
else
    echo "No draft files found to clean up for session $SHORT_SESSION_ID"
fi