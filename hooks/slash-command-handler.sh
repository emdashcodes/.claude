#!/bin/bash
# UserPromptSubmit Hook: Handle slash commands with session context

# Exit early if hooks are disabled
if [ "$CLAUDE_DISABLE_HOOKS" = "1" ]; then
    exit 0
fi

# Read JSON input
JSON_DATA=$(cat)

# Extract session ID and user prompt
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null)
USER_PROMPT=$(echo "$JSON_DATA" | jq -r '.prompt // ""' 2>/dev/null)

# Check for /spec:vibe command (slash commands use colon)
# if echo "$USER_PROMPT" | grep -q "^/spec:vibe"; then
    # spec-vibe
# fi
# Check for /spec:enforce command (slash commands use colon)
# if echo "$USER_PROMPT" | grep -q "^/spec:enforce"; then
    # spec-enforce
# fi

# Check for /pr-draft:approve command
if echo "$USER_PROMPT" | grep -q "^/pr-draft:approve"; then
    export CLAUDE_SESSION_ID="$SESSION_ID"
    exec ~/.claude/helpers/pr-draft-approve.sh
fi

# Check for /pr-draft:cancel command
if echo "$USER_PROMPT" | grep -q "^/pr-draft:cancel"; then
    export CLAUDE_SESSION_ID="$SESSION_ID"
    exec ~/.claude/helpers/pr-draft-cancel.sh
fi
