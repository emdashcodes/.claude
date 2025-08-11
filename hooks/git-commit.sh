#!/bin/bash
# Claude Code Hook: Git Commit Validator
# Validates: length, prefix format, single-line commits
# Blocks: -f, --no-verify flags (unless disabled)
# 
# To allow -f/--no-verify: Set ALLOW_FORCE_COMMIT=true below

# Manual override - set to true to allow -f and --no-verify flags
ALLOW_FORCE_COMMIT=false

# Read JSON input
JSON_DATA=$(cat)

# Extract tool name and command
TOOL_NAME=$(echo "$JSON_DATA" | jq -r '.tool_name // ""' 2>/dev/null)
COMMAND=$(echo "$JSON_DATA" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Only process Bash tool
if [ "$TOOL_NAME" != "Bash" ]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Check if this is a git commit command
if ! echo "$COMMAND" | grep -q "^git commit"; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Block -f and --no-verify flags (unless explicitly allowed)
if [ "$ALLOW_FORCE_COMMIT" != "true" ]; then
    if echo "$COMMAND" | grep -qE -- "(-f|--no-verify)"; then
        cat << EOF
{
  "decision": "block",
  "reason": "Force commits and skipping verification are not allowed!\n\nThe -f and --no-verify flags are blocked for safety.\n\nTo allow these flags, manually edit hooks/git-commit.sh and set ALLOW_FORCE_COMMIT=true"
}
EOF
        exit 0
    fi
fi

# Extract commit message
if echo "$COMMAND" | grep -q -- "-m"; then
    # Handle heredoc format: git commit -m "$(cat <<'EOF'...EOF)"
    if echo "$COMMAND" | grep -q "cat <<'EOF'"; then
        # Extract message between EOF markers
        COMMIT_MESSAGE=$(echo "$COMMAND" | sed -n "/cat <<'EOF'/,/EOF/p" | sed "1d;\$d")
    else
        # Extract message from -m flag
        COMMIT_MESSAGE=$(echo "$COMMAND" | sed -n 's/.*-m[[:space:]]*"\([^"]*\)".*/\1/p')
        if [ -z "$COMMIT_MESSAGE" ]; then
            COMMIT_MESSAGE=$(echo "$COMMAND" | sed -n "s/.*-m[[:space:]]*'\([^']*\)'.*/\1/p")
        fi
    fi
fi

# Check if we found a message
if [ -n "$COMMIT_MESSAGE" ]; then
    # Check for line breaks (multi-line commits)
    LINE_COUNT=$(echo "$COMMIT_MESSAGE" | wc -l)
    if [ "$LINE_COUNT" -gt 1 ]; then
        cat << EOF
{
  "decision": "block",
  "reason": "Multi-line commits not allowed! Please use a single-line commit message."
}
EOF
        exit 0
    fi

    # Check for valid prefix
    ALLOWED_PREFIXES="feat fix docs style refactor test chore perf ci build revert add update remove"
    HAS_VALID_PREFIX=false

    for prefix in $ALLOWED_PREFIXES; do
        if echo "$COMMIT_MESSAGE" | grep -q "^$prefix:"; then
            HAS_VALID_PREFIX=true
            break
        fi
    done

    if [ "$HAS_VALID_PREFIX" = "false" ]; then
        # Format prefixes with colons for display
        FORMATTED_PREFIXES=$(echo "$ALLOWED_PREFIXES" | sed 's/ /:, /g'):
        cat << EOF
{
  "decision": "block",
  "reason": "Invalid commit format!\n\nMust start with one of: $FORMATTED_PREFIXES\n\nYour message: '$COMMIT_MESSAGE'"
}
EOF
        exit 0
    fi

    # Check length
    MESSAGE_LENGTH=${#COMMIT_MESSAGE}
    if [ "$MESSAGE_LENGTH" -gt 75 ]; then
        cat << EOF
{
  "decision": "block",
  "reason": "Commit message too long: $MESSAGE_LENGTH characters (max: 75)"
}
EOF
        exit 0
    fi
fi

# Approve
echo '{"decision": "approve"}'
