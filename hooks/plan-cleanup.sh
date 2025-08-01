#!/bin/bash
# Claude Hook: Plan Cleanup and Approval Handler
#
# PURPOSE:
#   Handles the final stage of plan workflow - overwrites draft with approved version.
#   Updates status to approved and prepares for spec generation workflow.
#
# TRIGGERED BY:
#   Claude Code hook system after user approves a plan from exit_plan_mode
#   Typically runs after plan-extractor.sh has created the initial draft
#
# FUNCTIONALITY:
#   - Extracts approved plan content from hook JSON data
#   - Completely overwrites draft plan.md with approved version
#   - Updates status to "approved"
#   - Prompts for spec generation workflow
#
# WORKFLOW:
#   1. plan-extractor.sh creates draft plan when exit_plan_mode is called
#   2. User reviews and approves plan
#   3. plan-cleanup.sh overwrites with approved version
#   4. Spec generation workflow can begin
#
# CONFIGURATION:
#   Uses spec.json hierarchy via spec-config.sh helper
#
# OUTPUT:
#   - Overwrites plan.md in spec folder with approved version

# Exit early if hooks are disabled
if [ "$CLAUDE_DISABLE_HOOKS" = "1" ]; then
    exit 0
fi


# Read all input
JSON_DATA=$(cat)


# Extract session_id and plan content
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null || echo "unknown-$(date +%s)")

# Extract plan content for approved version
PLAN_CONTENT=$(echo "$JSON_DATA" | jq -r '.tool_input.plan' 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$PLAN_CONTENT" ] || [ "$PLAN_CONTENT" = "null" ]; then
    PLAN_CONTENT=$(echo "$JSON_DATA" | grep -o '"plan":"[^"]*"' | head -1 | sed 's/"plan":"//; s/"$//' | sed 's/\\n/\n/g; s/\\t/\t/g; s/\\"/"/g')

    if [ -z "$PLAN_CONTENT" ]; then
        PLAN_CONTENT=$(echo "$JSON_DATA" | sed -n 's/.*"plan":"\([^"]*\)".*/\1/p' | head -1 | sed 's/\\n/\n/g; s/\\t/\t/g; s/\\"/"/g')
    fi
fi

# Only process if we have valid plan content
if [ -n "$PLAN_CONTENT" ] && [ "$PLAN_CONTENT" != "# Plan Content Not Found" ]; then
    # Extract H1 title for slug generation
    H1_TITLE=$(echo -e "$PLAN_CONTENT" | grep -m1 '^# ' | sed 's/^# //' | head -1)
    if [ -z "$H1_TITLE" ]; then
        H1_TITLE="untitled-plan"
    fi

    # Get current directory name for context
    CURRENT_DIR_NAME=$(basename "$(pwd)")

    # Generate slug using Claude Code SDK with context (disable hooks to prevent recursion)
    SLUG=$(CLAUDE_DISABLE_HOOKS=1 claude -p "Convert this title to a kebab-case slug suitable for a folder name. Current project/directory is '$CURRENT_DIR_NAME' so avoid repeating that. Banned characters: # ^ [ ] |. Return ONLY the slug, nothing else: $H1_TITLE" 2>/dev/null)

    # Fallback if Claude fails
    if [ -z "$SLUG" ] || [ "$SLUG" = "null" ]; then
        # Manual slug generation as fallback
        SLUG=$(echo "$H1_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')
    fi

    # Clean up banned characters just in case
    SLUG=$(echo "$SLUG" | sed 's/[#^\[\]|]//g')

    # Get spec path from configuration
    SPEC_PATH=$(spec-config)
    SPEC_FOLDER="$SPEC_PATH$SLUG"

    # Create approved frontmatter
    APPROVED_FRONTMATTER="---
session_id: \"$SESSION_ID\"
status: \"approved\"
---
"

    # Overwrite plan.md with approved version
    echo -e "$APPROVED_FRONTMATTER$PLAN_CONTENT" > "$SPEC_FOLDER/plan.md"

    # Create state file for spec workflow enforcement
    STATE_DIR=".claude/state"
    mkdir -p "$STATE_DIR" 2>/dev/null
    echo "$SPEC_FOLDER/plan.md" > "$STATE_DIR/plan-approved-$SESSION_ID"

    # Remove any existing vibe check disable for this session - new plan approval re-enables enforcement
    rm -f "$STATE_DIR/spec-disabled-$SESSION_ID" 2>/dev/null

    # Clean up the pending marker if it exists
    rm -f "$STATE_DIR/plan-approved-$SESSION_ID.pending" 2>/dev/null

    echo "=================================================================================="
    echo "PLAN APPROVED AND READY FOR SPEC GENERATION!"
    echo "=================================================================================="
    echo ""
    echo "Plan Location: $SPEC_FOLDER/plan.md"
    echo "Session ID: $SESSION_ID"
    echo "Feature: $H1_TITLE"
    echo "Status: APPROVED"
    echo ""
    echo "NEXT STEPS:"
    echo "   1. Generate requirements from this approved plan"
    echo "   2. Review and approve the requirements"
    echo "   3. Generate implementation tasks"
    echo "   4. Begin coding with /spec:workflow:implement"
    echo ""
    echo "TO CONTINUE SPEC WORKFLOW:"
    echo "   Ask Claude: 'Generate requirements from the approved plan'"
    echo "   Or manually run: Task(..., subagent_type='spec-requirements')"
    echo ""
    echo "Spec Directory Structure:"
    echo "   $SPEC_FOLDER/"
    echo "   ├── plan.md          [APPROVED]"
    echo "   ├── requirements.md  [NEXT]"
    echo "   └── tasks.md         [AFTER REQUIREMENTS]"
    echo ""
    echo "=================================================================================="
else
    echo "No valid plan content found to approve"
fi