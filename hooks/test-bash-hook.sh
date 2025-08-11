#!/bin/bash
# Test hook to verify PreToolUse is working

# Read JSON input
JSON_DATA=$(cat)

# Extract command
COMMAND=$(echo "$JSON_DATA" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Log to file
echo "[$(date)] Test hook called with command: $COMMAND" >> /tmp/test-hook.log

# Always approve
echo '{"decision": "approve"}'