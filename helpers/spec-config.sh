#!/bin/bash
# Returns the configured spec path with proper hierarchy
# Checks: project .claude/config/spec.json → global ~/.claude/config/spec.json → default

if [ -f ".claude/config/spec.json" ]; then
  SPEC_PATH=$(jq -r '.specs_path // ".claude/specs/"' .claude/config/spec.json)
elif [ -f "$HOME/.claude/config/spec.json" ]; then
  SPEC_PATH=$(jq -r '.specs_path // ".claude/specs/"' "$HOME/.claude/config/spec.json")
else
  SPEC_PATH=".claude/specs/"
fi

# Ensure path ends with slash
[[ "${SPEC_PATH}" != */ ]] && SPEC_PATH="${SPEC_PATH}/"

echo "$SPEC_PATH"
