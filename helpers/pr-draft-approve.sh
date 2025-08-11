#!/bin/bash
# PR Draft Approve Helper
# Updates lock file status to approved and displays draft for confirmation

# Get session ID from environment
SESSION_ID="${CLAUDE_SESSION_ID:-$$}"

# State directory
STATE_DIR=".claude/state"
LOCK_FILE="$STATE_DIR/pr-draft-$SESSION_ID.lock"

# Check if lock file exists
if [ ! -f "$LOCK_FILE" ]; then
    echo "❌ No PR draft found for session: $SESSION_ID"
    echo "   No pending PR to approve"
    exit 1
fi

# Read lock file
LOCK_STATUS=$(jq -r '.status // "pending"' "$LOCK_FILE" 2>/dev/null)
DRAFT_FILE=$(jq -r '.draft_file // ""' "$LOCK_FILE" 2>/dev/null)
COMMAND=$(jq -r '.command // ""' "$LOCK_FILE" 2>/dev/null)

if [ "$LOCK_STATUS" = "approved" ]; then
    echo "✅ PR draft already approved for session: $SESSION_ID"
    echo "   Re-run your gh pr create command to submit"
    exit 0
fi

# Display draft content for review
echo "📝 PR Draft Review"
echo "=================="
if [ -f "$DRAFT_FILE" ]; then
    cat "$DRAFT_FILE"
    echo ""
    echo "=================="
fi

# Update lock status to approved
jq '.status = "approved" | .approved_at = now' "$LOCK_FILE" > "$LOCK_FILE.tmp" && mv "$LOCK_FILE.tmp" "$LOCK_FILE"

echo ""
echo "✅ PR draft APPROVED for session: $SESSION_ID"
echo ""
echo "📤 Now re-run your gh pr create command to submit the PR."
echo ""
echo "The PR will be automatically submitted and the draft will be cleaned up."