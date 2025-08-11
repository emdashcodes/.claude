#!/bin/bash
# Find session log by session ID

if [ $# -lt 1 ]; then
    echo "Usage: $0 <session_id> [search_path]" >&2
    exit 1
fi

SESSION_ID="$1"
SEARCH_PATH="${2:-$(cat ~/.claude/config/vault.json | jq -r '.sessions_path')}"
SEARCH_PATH="${SEARCH_PATH/#\~/$HOME}"

# Search for files containing the session ID
find "$SEARCH_PATH" -name "*.md" -type f 2>/dev/null | while read -r file; do
    if grep -q "session_ids:.*$SESSION_ID" "$file" 2>/dev/null; then
        echo "$file"
        exit 0
    fi
done

exit 1