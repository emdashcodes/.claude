#!/bin/bash

# Ollama API utility
# Provides helper functions for interacting with Ollama

ollama_generate() {
    local MODEL="$1"
    local PROMPT="$2"
    local TEMPERATURE="${3:-0.1}"
    local OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"

    curl -s "$OLLAMA_HOST/api/generate" \
        -d "{
            \"model\": \"$MODEL\",
            \"prompt\": $(echo "$PROMPT" | jq -Rs .),
            \"stream\": false,
            \"options\": {
                \"temperature\": $TEMPERATURE
            }
        }"
}

# Extract response content from Ollama API response
ollama_extract_response() {
    local RESPONSE="$1"
    echo "$RESPONSE" | jq -r '.response // empty' 2>/dev/null
}
