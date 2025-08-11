#!/bin/bash
# Claude Code Hook: GitHub PR Draft Review
# Intercepts gh pr create commands and enforces review workflow
# Uses session-specific lock files with state management

# Read JSON input
JSON_DATA=$(cat)

# Extract tool name and command
TOOL_NAME=$(echo "$JSON_DATA" | jq -r '.tool_name // ""' 2>/dev/null)
COMMAND=$(echo "$JSON_DATA" | jq -r '.tool_input.command // ""' 2>/dev/null)
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id // ""' 2>/dev/null)

# Only process Bash tool
if [ "$TOOL_NAME" != "Bash" ]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Check if this is a gh pr create command
if ! echo "$COMMAND" | grep -q "^gh pr create"; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Load configuration
CONFIG_FILE="$HOME/.claude/config/pr-draft-config.json"
if [ -f "$CONFIG_FILE" ]; then
    DRAFT_DIR=$(jq -r '.draft_dir // ".claude/drafts"' "$CONFIG_FILE" 2>/dev/null)
else
    DRAFT_DIR=".claude/drafts"
fi

# Ensure draft directory exists
mkdir -p "$DRAFT_DIR" 2>/dev/null

# Create state directory if it doesn't exist
STATE_DIR=".claude/state"
mkdir -p "$STATE_DIR" 2>/dev/null

# Lock file path
if [ -z "$SESSION_ID" ]; then
    # Fallback to PID if no session ID
    LOCK_FILE="$STATE_DIR/pr-draft-$$.lock"
else
    LOCK_FILE="$STATE_DIR/pr-draft-$SESSION_ID.lock"
fi

# Check lock file status
if [ -f "$LOCK_FILE" ]; then
    LOCK_STATUS=$(jq -r '.status // "pending"' "$LOCK_FILE" 2>/dev/null)
    
    if [ "$LOCK_STATUS" = "approved" ]; then
        # Approved - allow command to proceed
        # Clean up after execution
        echo "{\"decision\": \"approve\", \"post_action\": \"cleanup\"}" > "$LOCK_FILE.action"
        
        # Set up cleanup trap (will be executed after command)
        cat << 'CLEANUP_SCRIPT' > "$LOCK_FILE.cleanup"
#!/bin/bash
# Clean up lock and draft files after successful PR creation
LOCK_FILE="$1"
DRAFT_FILE="$2"
rm -f "$LOCK_FILE" "$LOCK_FILE.action" "$LOCK_FILE.cleanup" 2>/dev/null
rm -f "$DRAFT_FILE" 2>/dev/null
CLEANUP_SCRIPT
        chmod +x "$LOCK_FILE.cleanup"
        
        echo '{"decision": "approve"}'
        
        # Schedule cleanup (non-blocking)
        (sleep 2 && "$LOCK_FILE.cleanup" "$LOCK_FILE" "$DRAFT_DIR/pr-draft-$SESSION_ID.md" &) 2>/dev/null
        
        exit 0
    fi
fi

# Extract PR content from command
PR_TITLE=""
PR_BODY=""

# Extract title if present
if echo "$COMMAND" | grep -q -- "--title"; then
    PR_TITLE=$(echo "$COMMAND" | sed -n 's/.*--title[[:space:]]*"\([^"]*\)".*/\1/p')
    if [ -z "$PR_TITLE" ]; then
        PR_TITLE=$(echo "$COMMAND" | sed -n "s/.*--title[[:space:]]*'\([^']*\)'.*/\1/p")
    fi
fi

# Extract body if present
if echo "$COMMAND" | grep -q -- "--body"; then
    # Handle heredoc format
    if echo "$COMMAND" | grep -q "cat <<'EOF'"; then
        PR_BODY=$(echo "$COMMAND" | sed -n "/cat <<'EOF'/,/EOF/p" | sed "1d;\$d")
    else
        PR_BODY=$(echo "$COMMAND" | sed -n 's/.*--body[[:space:]]*"\([^"]*\)".*/\1/p')
        if [ -z "$PR_BODY" ]; then
            PR_BODY=$(echo "$COMMAND" | sed -n "s/.*--body[[:space:]]*'\([^']*\)'.*/\1/p")
        fi
    fi
fi

# Save draft content - just the actual PR content
DRAFT_FILE="$DRAFT_DIR/pr-draft-$SESSION_ID.md"
cat > "$DRAFT_FILE" << EOF
Title: $PR_TITLE

Body:
$PR_BODY
EOF

# Create or update lock file with pending status
cat > "$LOCK_FILE" << EOF
{
  "status": "pending",
  "session_id": "$SESSION_ID",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "draft_file": "$DRAFT_FILE",
  "command": $(echo "$COMMAND" | jq -Rs .)
}
EOF

# Load and display template
TEMPLATE_FILE="$HOME/.claude/templates/pr-template.md"
TEMPLATE_CONTENT=""
if [ -f "$TEMPLATE_FILE" ]; then
    # Escape template content for JSON
    TEMPLATE_CONTENT=$(cat "$TEMPLATE_FILE" | jq -Rs . | sed 's/^"//;s/"$//')
fi

# Block the command with guidance - properly escape the reason field
REASON="PR Draft Review Required

Your PR draft has been saved for review.

$TEMPLATE_CONTENT

To approve and submit: /pr-draft:approve
To cancel: /pr-draft:cancel

Draft saved to: $DRAFT_FILE"

# Output properly formatted JSON
jq -n \
  --arg decision "block" \
  --arg reason "$REASON" \
  '{decision: $decision, reason: $reason}'