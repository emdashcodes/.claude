#!/bin/bash
# Universal Hook Logger Script

# Ensure log directory exists
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

# Create log file with timestamp
LOG_FILE="$LOG_DIR/hooks-$(date +%Y%m%d).log"

# Read all input
JSON_DATA=$(cat)

# Get current timestamp
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Extract common fields
HOOK_EVENT=$(echo "$JSON_DATA" | jq -r '.hook_event_name' 2>/dev/null || echo "unknown")
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null || echo "unknown")
CWD=$(echo "$JSON_DATA" | jq -r '.cwd' 2>/dev/null || echo "unknown")
TRANSCRIPT=$(echo "$JSON_DATA" | jq -r '.transcript_path' 2>/dev/null || echo "unknown")

# Log separator for readability
echo "================================================================================" >> "$LOG_FILE"
echo "[$TIMESTAMP] Hook Event: $HOOK_EVENT" >> "$LOG_FILE"
echo "Session ID: $SESSION_ID" >> "$LOG_FILE"
echo "Working Dir: $CWD" >> "$LOG_FILE"
echo "Transcript: $TRANSCRIPT" >> "$LOG_FILE"
echo "--------------------------------------------------------------------------------" >> "$LOG_FILE"

# Pretty print the full JSON data
echo "$JSON_DATA" | jq '.' 2>/dev/null >> "$LOG_FILE" || echo "$JSON_DATA" >> "$LOG_FILE"

# Log specific fields based on hook type
case "$HOOK_EVENT" in
    "UserPromptSubmit")
        PROMPT=$(echo "$JSON_DATA" | jq -r '.prompt' 2>/dev/null)
        echo "User Prompt: $PROMPT" >> "$LOG_FILE"
        ;;
    "PreToolUse")
        TOOL_NAME=$(echo "$JSON_DATA" | jq -r '.tool_name' 2>/dev/null)
        TOOL_INPUT=$(echo "$JSON_DATA" | jq '.tool_input' 2>/dev/null)
        echo "Tool Name: $TOOL_NAME" >> "$LOG_FILE"
        echo "Tool Input: $TOOL_INPUT" >> "$LOG_FILE"
        ;;
    "PostToolUse")
        TOOL_NAME=$(echo "$JSON_DATA" | jq -r '.tool_name' 2>/dev/null)
        TOOL_INPUT=$(echo "$JSON_DATA" | jq '.tool_input' 2>/dev/null)
        TOOL_RESPONSE=$(echo "$JSON_DATA" | jq '.tool_response' 2>/dev/null)
        echo "Tool Name: $TOOL_NAME" >> "$LOG_FILE"
        echo "Tool Input: $TOOL_INPUT" >> "$LOG_FILE"
        echo "Tool Response: $TOOL_RESPONSE" >> "$LOG_FILE"
        ;;
    "Notification")
        MESSAGE=$(echo "$JSON_DATA" | jq -r '.message' 2>/dev/null)
        echo "Notification Message: $MESSAGE" >> "$LOG_FILE"
        ;;
    "Stop"|"SubagentStop")
        STOP_HOOK_ACTIVE=$(echo "$JSON_DATA" | jq -r '.stop_hook_active' 2>/dev/null)
        echo "Stop Hook Active: $STOP_HOOK_ACTIVE" >> "$LOG_FILE"
        ;;
    "PreCompact")
        TRIGGER=$(echo "$JSON_DATA" | jq -r '.trigger' 2>/dev/null)
        CUSTOM_INSTRUCTIONS=$(echo "$JSON_DATA" | jq -r '.custom_instructions' 2>/dev/null)
        echo "Trigger: $TRIGGER" >> "$LOG_FILE"
        echo "Custom Instructions: $CUSTOM_INSTRUCTIONS" >> "$LOG_FILE"
        ;;
esac

echo "" >> "$LOG_FILE"

# Also output to console for debugging
# echo "[$TIMESTAMP] Logged $HOOK_EVENT to $LOG_FILE"
