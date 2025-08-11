#!/bin/bash
# Session Start Hook - Creates or updates session logs in Grimoire
# Read input from Claude Code
JSON_DATA=$(cat)

# Extract hook data
HOOK_EVENT=$(echo "$JSON_DATA" | jq -r '.hook_event_name' 2>/dev/null || echo "unknown")
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null || echo "unknown")
# Get current working directory (not provided in hook data)
CWD=$(pwd)
SOURCE=$(echo "$JSON_DATA" | jq -r '.source' 2>/dev/null || echo "unknown")
TRANSCRIPT_PATH=$(echo "$JSON_DATA" | jq -r '.transcript_path' 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
DATE=$(date +%Y-%m-%d)
