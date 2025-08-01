#!/bin/bash
# Claude Hook: Spec Workflow Enforcer
#
# PURPOSE:
#   Ensures spec workflow continues after ExitPlanMode by blocking non-agent actions
#   until requirements generation is initiated.
#
# TRIGGERED BY:
#   PreToolUse hook for any tool after ExitPlanMode approval
#
# FUNCTIONALITY:
#   - Detects when previous action was ExitPlanMode approval
#   - Blocks non-agent Task tools with helpful reminder
#   - Allows agent-based Task tools to proceed
#   - Clears state once spec workflow is initiated

# Exit early if hooks are disabled
if [ "$CLAUDE_DISABLE_HOOKS" = "1" ]; then
    echo '{"decision": "approve"}'
    exit 0
fi



# Read JSON input
JSON_DATA=$(cat)

# Extract session ID
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null || echo "unknown")

# Extract tool name from JSON since CLAUDE_TOOL_NAME env var is not set
TOOL_NAME=$(echo "$JSON_DATA" | jq -r '.tool_name // ""' 2>/dev/null)
if [ -z "$TOOL_NAME" ] && [ -n "$CLAUDE_TOOL_NAME" ]; then
    TOOL_NAME="$CLAUDE_TOOL_NAME"
fi

# NEVER interfere with ExitPlanMode - it has its own approval mechanism
if [ "$TOOL_NAME" = "ExitPlanMode" ]; then
    # Return empty output for ExitPlanMode - let it handle everything itself
    exit 0
fi

# State directory and file - use pwd to ensure project-specific state
PROJECT_ROOT="$(pwd)"
STATE_DIR="$PROJECT_ROOT/.claude/state"
STATE_FILE="$STATE_DIR/plan-approved-$SESSION_ID"
DISABLE_FILE="$STATE_DIR/spec-disabled-$SESSION_ID"

# Check if enforcement is disabled for this session
if [ -f "$DISABLE_FILE" ]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Check if we're in post-plan-approval state
if [ -f "$STATE_FILE" ]; then

    # Check if current tool is Task
    if [ "$TOOL_NAME" = "Task" ]; then
        # Extract agent type from tool input
        AGENT_TYPE=$(echo "$JSON_DATA" | jq -r '.tool_input.subagent_type // ""' 2>/dev/null)

        # Check if it's a spec-related or implementation agent
        if [[ "$AGENT_TYPE" == "spec-requirements" ]] || \
           [[ "$AGENT_TYPE" == "general-purpose" ]] || \
           [[ "$AGENT_TYPE" == "spec-reviewer" ]] || \
           [[ "$AGENT_TYPE" == "spec-tasks" ]]; then
            # This is good - spec workflow or implementation is starting
            rm -f "$STATE_FILE"  # Clear the state

            # Allow the action
            echo '{"decision": "approve"}'
            exit 0
        fi
    fi

    # For any other tool or non-spec agent, block with instructions

    # Get the approved plan location from state file
    PLAN_LOCATION=$(cat "$STATE_FILE" 2>/dev/null || echo ".claude/specs/[recent-plan]/plan.md")

    # Block with helpful message
    cat << EOF
{
  "decision": "block",
  "reason": "SPEC WORKFLOW: Plan approved! Next step is generating requirements.\n\nPlan location: $PLAN_LOCATION\n\nTo continue the spec workflow:\n   -> Say: 'Generate requirements from the approved plan'\n   -> Or use: Task('Generate requirements', 'Create requirements from plan at $PLAN_LOCATION', 'spec-requirements')\n\nTo skip spec workflow (not recommended):\n   -> Use: /spec:vibe\n\nThe spec workflow helps ensure thorough planning and implementation!"
}
EOF
    exit 0
fi


# Default: allow all other actions
echo '{"decision": "approve"}'
exit 0