#!/bin/bash
# Shared logging function for session hooks

LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/session-hooks-$(date +%Y%m%d).log"

log_message() {
    local hook_name="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$hook_name] $message" >> "$LOG_FILE"
}

# Also log JSON input if DEBUG is set
if [ "$DEBUG_HOOKS" = "1" ]; then
    log_message "$HOOK_NAME" "Input JSON: $JSON_DATA"
fi