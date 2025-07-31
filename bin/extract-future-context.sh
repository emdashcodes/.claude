#!/bin/bash
# Extract future context from the most recent completed session

# Get vault paths
VAULT_CONFIG=$(cat ~/.claude/vault.json)
SESSIONS_PATH=$(echo "$VAULT_CONFIG" | jq -r '.sessions_path')
SESSIONS_PATH="${SESSIONS_PATH/#\~/$HOME}"

# Find most recent end-session.md file
LAST_SESSION=$(find "$SESSIONS_PATH" -name "end-session.md" -type f 2>/dev/null | \
    xargs ls -t 2>/dev/null | head -1)

if [ -z "$LAST_SESSION" ]; then
    echo "No completed sessions found" >&2
    exit 1
fi

# Extract Future Context section
awk '
/^## Future Context/ { capture = 1; next }
/^##[^#]/ { capture = 0 }
/^---$/ { capture = 0 }
capture && !/^$/ { print }
' "$LAST_SESSION"