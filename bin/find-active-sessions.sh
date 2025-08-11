#!/bin/bash
# Find all active session logs for today

# Get vault paths
VAULT_CONFIG=$(cat ~/.claude/config/vault.json)
SESSIONS_PATH=$(echo "$VAULT_CONFIG" | jq -r '.sessions_path')
SESSIONS_PATH="${SESSIONS_PATH/#\~/$HOME}"
TODAY_PATH="$SESSIONS_PATH/$(date +%Y/%m/%d)"

# Find all active sessions
if [ -d "$TODAY_PATH" ]; then
    find "$TODAY_PATH" -name "*.md" -type f 2>/dev/null | while read -r file; do
        # Check if status is active
        if grep -q "^status: active" "$file" 2>/dev/null; then
            echo "$file"
        fi
    done
fi