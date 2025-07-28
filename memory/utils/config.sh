#!/bin/bash

# Unified configuration for the memory system
# Source this file to load all configuration variables

# Models
export MEMORY_CLASSIFIER_MODEL="gemma2:2b-instruct-q4_K_M"
export MEMORY_SEARCH_MODEL="qwen3:8b"

# API Endpoints
export OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"

# Classification Settings
export MEMORY_CONFIDENCE_THRESHOLD="${MEMORY_CONFIDENCE_THRESHOLD:-0.7}"

# Debug Settings
export MEMORY_HOOK_DEBUG="${MEMORY_HOOK_DEBUG:-true}"
export MEMORY_HOOK_LOG="${MEMORY_HOOK_LOG:-/tmp/claude-memory-hook.log}"

# Paths
export MEMORY_BIN_DIR="${HOME}/.claude/memory/bin"
export MEMORY_UTILS_DIR="${HOME}/.claude/memory/utils"

# MCPHost Settings
export MCPHOST_COMMAND="mcphost"
