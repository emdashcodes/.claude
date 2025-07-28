#!/bin/bash

# Memory Context Injection Hook for Claude Code
# This hook intercepts user prompts and adds relevant memory context

set -euo pipefail

# Source configuration
source "${HOME}/.claude/memory/utils/config.sh"

# Source utilities
source "${HOME}/.claude/memory/utils/debug-log.sh"
source "${HOME}/.claude/memory/utils/json-extract.sh"

HOOK_INPUT=$(cat)
debug_log "Received hook input: $HOOK_INPUT"

USER_PROMPT=$(json_get "$HOOK_INPUT" '.prompt' '')
if [ -z "$USER_PROMPT" ]; then
    debug_log "No prompt found in hook input"
    exit 0
fi

# Use the classifier to check if memory is needed
debug_log "Running memory-classifier"
debug_log "Classifier input: $USER_PROMPT"
CLASSIFICATION=$(echo "$USER_PROMPT" | "${MEMORY_BIN_DIR}/memory-classifier" 2>>"$MEMORY_HOOK_LOG") || {
    debug_log "Classifier failed with exit code: $?"
    CLASSIFICATION='{"needs_memory": false, "confidence": 0, "reason": "Classifier failed"}'
}
debug_log "Classification result: $CLASSIFICATION"

NEEDS_MEMORY=$(json_get "$CLASSIFICATION" '.needs_memory' 'false')
CONFIDENCE=$(json_get "$CLASSIFICATION" '.confidence' '0')

if [ "$NEEDS_MEMORY" != "true" ] || (( $(echo "$CONFIDENCE < $MEMORY_CONFIDENCE_THRESHOLD" | bc -l) )); then
    debug_log "Memory not needed (needs_memory=$NEEDS_MEMORY) or confidence too low ($CONFIDENCE < $MEMORY_CONFIDENCE_THRESHOLD)"
    exit 0
fi

debug_log "Memory needed for prompt: $USER_PROMPT"

# Use memory search (wrapper)
MEMORY_SEARCH="${MEMORY_BIN_DIR}/memory-search"
if [ -f "$MEMORY_SEARCH" ] && [ -x "$MEMORY_SEARCH" ]; then
    debug_log "Running memory search with model: $MEMORY_SEARCH_MODEL"
    debug_log "User prompt: $USER_PROMPT"

    MEMORY_CONTEXT=$("$MEMORY_SEARCH" --model "$MEMORY_SEARCH_MODEL" --args:USER_PROMPT "$USER_PROMPT" --quiet 2>/dev/null) || {
        debug_log "Search failed with exit code: $?"
        MEMORY_CONTEXT=""
    }
else
    debug_log "Memory search not found or not executable"
    MEMORY_CONTEXT=""
fi

debug_log "Extracted memory context: $MEMORY_CONTEXT"

# Check if we actually found meaningful memory content
if [ -n "$MEMORY_CONTEXT" ] && [ "$MEMORY_CONTEXT" != "null" ] && [ "$MEMORY_CONTEXT" != "" ] && [ "$MEMORY_CONTEXT" != "No relevant memory found" ]; then
    debug_log "Found memory context, injecting into prompt"

    # Clean up the memory context (remove excessive newlines)
    MEMORY_CONTEXT=$(echo "$MEMORY_CONTEXT" | sed '/^$/N;/^\n$/d')

    echo "## Memory Context"
    echo ""
    echo "$MEMORY_CONTEXT"
    echo ""
else
    # Don't output anything - let the original prompt pass through unchanged
    debug_log "No relevant memory found"
fi
