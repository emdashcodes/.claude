#!/bin/bash
# PR Draft Cancel Helper
# Removes lock file and draft, canceling the PR submission

# Get session ID from environment
SESSION_ID="${CLAUDE_SESSION_ID:-$$}"

# State directory and config
STATE_DIR=".claude/state"
LOCK_FILE="$STATE_DIR/pr-draft-$SESSION_ID.lock"

# Load configuration for draft directory
CONFIG_FILE="$HOME/.claude/config/pr-draft-config.json"
if [ -f "$CONFIG_FILE" ]; then
    DRAFT_DIR=$(jq -r '.draft_dir // ".claude/drafts"' "$CONFIG_FILE" 2>/dev/null)
else
    DRAFT_DIR=".claude/drafts"
fi

# Check if lock file exists
if [ ! -f "$LOCK_FILE" ]; then
    echo "No PR draft found for session: $SESSION_ID"
    echo "Nothing to cancel"
    exit 1
fi

# Read draft file path from lock
DRAFT_FILE=$(jq -r '.draft_file // ""' "$LOCK_FILE" 2>/dev/null)

# Remove lock file and related files
rm -f "$LOCK_FILE" "$LOCK_FILE.action" "$LOCK_FILE.cleanup" 2>/dev/null

# Remove draft file if it exists
if [ -n "$DRAFT_FILE" ] && [ -f "$DRAFT_FILE" ]; then
    rm -f "$DRAFT_FILE"
    echo "Removed draft: $DRAFT_FILE"
fi

# Also try to remove session-specific draft in case path changed
rm -f "$DRAFT_DIR/pr-draft-$SESSION_ID.md" 2>/dev/null

echo ""
echo "PR draft CANCELLED for session: $SESSION_ID"
echo "Lock and draft files have been removed"
echo "You can create a new PR draft at any time"