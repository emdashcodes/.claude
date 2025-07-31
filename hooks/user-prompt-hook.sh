#!/bin/bash
# User Prompt Hook - Sets session title and injects context from previous sessions

# Debug logging
DEBUG_LOG="$HOME/.claude/session-hook-debug.log"
echo "[$(date)] UserPromptSubmit hook triggered" >> "$DEBUG_LOG"

# Read input from Claude Code
JSON_DATA=$(cat)

# Log the input
echo "[$(date)] UserPrompt JSON: $JSON_DATA" >> "$DEBUG_LOG"

# Extract hook data
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null || echo "unknown")
PROMPT=$(echo "$JSON_DATA" | jq -r '.prompt' 2>/dev/null || echo "")
# Working directory not provided in UserPromptSubmit hook
CWD=$(pwd)

# Get vault paths
VAULT_CONFIG=$(cat ~/.claude/vault.json)
SESSIONS_PATH=$(echo "$VAULT_CONFIG" | jq -r '.sessions_path')
SESSIONS_PATH="${SESSIONS_PATH/#\~/$HOME}"
TODAY_PATH="$SESSIONS_PATH/$(date +%Y/%m/%d)"

# Function to find current session by ID
find_current_session() {
    local search_id="$1"
    find "$TODAY_PATH" -name "*.md" -type f 2>/dev/null | while read -r file; do
        # Check if session ID exists in the file (accounting for array format)
        if grep -A20 "^session_ids:" "$file" 2>/dev/null | grep -q "\"$search_id\""; then
            echo "$file"
            return 0
        fi
    done
    return 1
}

# Function to check if session needs title
needs_title() {
    local file="$1"
    local basename=$(basename "$file" .md)
    # Check if filename is just a number (like "01.md")
    if [[ "$basename" =~ ^[0-9]+$ ]]; then
        return 0
    fi
    return 1
}

# Function to generate title from prompt
generate_title() {
    local prompt="$1"
    
    # Use AdaScript file to generate a concise title
    local script_path="$HOME/.claude/scripts/generate-session-title.md"
    
    if [ -f "$script_path" ]; then
        local title=$(adascript "$script_path" --model "anthropic:claude-3-5-haiku-latest" --args:USER_PROMPT "$prompt" --output-format text 2>/dev/null | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    else
        echo "[$(date)] Warning: AdaScript file not found at $script_path" >> "$DEBUG_LOG"
        local title=""
    fi
    
    # Fallback if AdaScript fails
    if [ -z "$title" ] || [ "$title" = "null" ]; then
        # Simple fallback: first 50 chars, remove banned chars
        title=$(echo "$prompt" | cut -c1-50 | sed 's/[#\^\[\]|]//g')
        # Capitalize first letter
        title="$(echo "$title" | sed 's/^./\U&/')"
    fi
    
    # Default to "Working" if still empty
    if [ -z "$title" ]; then
        title="Working"
    fi
    
    echo "$title"
}

# Function to extract future context from last completed session
get_future_context() {
    # Find most recent completed session (end-session.md files)
    local last_session=$(find "$SESSIONS_PATH" -name "end-session.md" -type f 2>/dev/null | \
        xargs ls -t 2>/dev/null | head -1)
    
    if [ -z "$last_session" ]; then
        return 1
    fi
    
    # Extract Future Context section
    awk '
    /^## Future Context/ { capture = 1; next }
    /^##[^#]/ { capture = 0 }
    /^---$/ { capture = 0 }
    capture && !/^$/ { print }
    ' "$last_session" 2>/dev/null
}

# Initialize output
OUTPUT_JSON="{}"
ADDITIONAL_CONTEXT=""

# Find current session
CURRENT_SESSION=$(find_current_session "$SESSION_ID")
echo "[$(date)] Found session: $CURRENT_SESSION" >> "$DEBUG_LOG"

if [ -n "$CURRENT_SESSION" ] && needs_title "$CURRENT_SESSION"; then
    echo "[$(date)] Session needs title" >> "$DEBUG_LOG"
    # Generate and set title
    TITLE=$(generate_title "$PROMPT")
    echo "[$(date)] Generated title: $TITLE" >> "$DEBUG_LOG"
    SESSION_DIR=$(dirname "$CURRENT_SESSION")
    SESSION_ID_NUM=$(basename "$CURRENT_SESSION" .md)
    NEW_FILENAME="$SESSION_ID_NUM - $TITLE.md"
    NEW_PATH="$SESSION_DIR/$NEW_FILENAME"
    
    # Rename file
    if mv "$CURRENT_SESSION" "$NEW_PATH" 2>/dev/null; then
        echo "[$(date)] Renamed file to: $NEW_PATH" >> "$DEBUG_LOG"
    else
        echo "[$(date)] Failed to rename file" >> "$DEBUG_LOG"
    fi
    
    # Update the title in the file content
    sed -i '' "s/^# $SESSION_ID_NUM$/# $TITLE/" "$NEW_PATH" 2>/dev/null
    
    echo "Set session title: $TITLE" >&2
else
    echo "[$(date)] Session doesn't need title or not found" >> "$DEBUG_LOG"
fi

# Get future context from previous session
FUTURE_CONTEXT=$(get_future_context)
if [ -n "$FUTURE_CONTEXT" ]; then
    ADDITIONAL_CONTEXT="Context from previous session's Future Context section:\n$FUTURE_CONTEXT\n\n"
    echo "Injected context from previous session" >&2
fi

# Build output JSON
if [ -n "$ADDITIONAL_CONTEXT" ]; then
    # Escape the context for JSON
    ESCAPED_CONTEXT=$(echo -e "$ADDITIONAL_CONTEXT" | jq -Rs .)
    OUTPUT_JSON=$(jq -n --argjson context "$ESCAPED_CONTEXT" '{
        "additionalContext": $context
    }')
fi

# Output the result
echo "$OUTPUT_JSON"