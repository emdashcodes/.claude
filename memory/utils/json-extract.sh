#!/bin/bash

# JSON extraction utility
# Provides helper functions for extracting JSON from various sources

# Extract JSON from a string that might contain code blocks or raw JSON
extract_json() {
    local CONTENT="$1"
    local JSON_CONTENT=""

    # First try to extract from code blocks
    JSON_CONTENT=$(echo "$CONTENT" | sed -n '/```json/,/```/p' | sed '1d;$d' 2>/dev/null)

    # If not in code block, try to find raw JSON
    if [ -z "$JSON_CONTENT" ]; then
        JSON_CONTENT=$(echo "$CONTENT" | grep -o '{[^}]*}' | head -1)
    fi

    # Validate it's valid JSON
    if [ -n "$JSON_CONTENT" ] && echo "$JSON_CONTENT" | jq . >/dev/null 2>&1; then
        echo "$JSON_CONTENT"
        return 0
    else
        return 1
    fi
}

# Safe JSON field extraction with default value
json_get() {
    local JSON="$1"
    local FIELD="$2"
    local DEFAULT="${3:-}"

    local VALUE=$(echo "$JSON" | jq -r "$FIELD // empty" 2>/dev/null)

    if [ -z "$VALUE" ] || [ "$VALUE" = "null" ]; then
        echo "$DEFAULT"
    else
        echo "$VALUE"
    fi
}
