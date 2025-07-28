#!/bin/bash
# Claude Hook: Spec Plan Approval Handler
#
# PURPOSE:
#   Updates the plan status from "draft" to "approved" when user confirms a plan.
#   Triggers the next phase of spec workflow (requirements generation).
#
# TRIGGERED BY:
#   Claude Code hook system after user approves a plan from exit_plan_mode
#
# FUNCTIONALITY:
#   - Reads the spec directory path stored by plan-extractor.sh
#   - Updates the plan.md status in frontmatter from "draft" to "approved"
#   - Signals that requirements generation can begin
#   - Removes the temporary session file
#
# WORKFLOW:
#   1. plan-extractor.sh creates spec folder with draft plan
#   2. User reviews and approves plan
#   3. plan-cleanup.sh updates status to approved
#   4. Spec workflow continues with requirements generation
#
# OUTPUT:
#   - Updates: [spec_dir]/plan.md status field
#   - Triggers: Requirements generation phase

# Read all input
JSON_DATA=$(cat)

# Extract session_id
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null || echo "unknown")

# Get the spec directory from the temporary file
TEMP_FILE="/tmp/claude-spec-dir-$SESSION_ID"
if [ ! -f "$TEMP_FILE" ]; then
    echo "Warning: Could not find spec directory file for session $SESSION_ID" >&2
    exit 0
fi

SPEC_DIR=$(cat "$TEMP_FILE")
PLAN_FILE="$SPEC_DIR/plan.md"

if [ ! -f "$PLAN_FILE" ]; then
    echo "Warning: Plan file not found at $PLAN_FILE" >&2
    rm -f "$TEMP_FILE"
    exit 0
fi

# Update the status in plan.md from "draft" to "approved"
# Using sed to update the status line in the frontmatter
sed -i.bak 's/^status: draft$/status: approved/' "$PLAN_FILE"

# Verify the update worked
if grep -q "status: approved" "$PLAN_FILE"; then
    echo "Plan approved: $PLAN_FILE"
    echo "Ready for requirements generation phase"
    rm -f "${PLAN_FILE}.bak"
else
    echo "Error: Failed to update plan status" >&2
    # Restore backup if update failed
    mv "${PLAN_FILE}.bak" "$PLAN_FILE"
fi

# Clean up temporary file
rm -f "$TEMP_FILE"

# Extract feature name from spec directory for notification
FEATURE_NAME=$(basename "$SPEC_DIR")
echo "Spec '$FEATURE_NAME' plan approved and ready for next phase"