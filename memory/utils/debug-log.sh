#!/bin/bash

# Debug logging utility
# Usage: source this file then use debug_log "message"

debug_log() {
    local DEBUG_MODE="${MEMORY_HOOK_DEBUG:-true}"
    local LOG_FILE="${MEMORY_HOOK_LOG:-/tmp/claude-memory-hook.log}"

    if [ "$DEBUG_MODE" = "true" ]; then
        echo "[DEBUG] $*" >&2
        # Also log to a file for debugging
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
    fi
}
