#!/bin/bash
# PreCompact Hook - Updates session log with progress before context compaction

# Read input from Claude Code
JSON_DATA=$(cat)

# Extract hook data
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null || echo "unknown")
TRIGGER=$(echo "$JSON_DATA" | jq -r '.trigger' 2>/dev/null || echo "unknown")
CUSTOM_INSTRUCTIONS=$(echo "$JSON_DATA" | jq -r '.custom_instructions' 2>/dev/null || echo "")
TIMESTAMP=$(date +"%Y-%m-%d %H:%M")

# Get vault paths
VAULT_CONFIG=$(cat ~/.claude/vault.json)
SESSIONS_PATH=$(echo "$VAULT_CONFIG" | jq -r '.sessions_path')
SESSIONS_PATH="${SESSIONS_PATH/#\~/$HOME}"
TODAY_PATH="$SESSIONS_PATH/$(date +%Y/%m/%d)"

# Function to find current session by ID
find_current_session() {
    local search_id="$1"
    find "$TODAY_PATH" -name "*.md" -type f 2>/dev/null | while read -r file; do
        if grep -q "session_ids:.*$search_id" "$file" 2>/dev/null; then
            echo "$file"
            return 0
        fi
    done
    return 1
}

# Function to extract todo progress
get_todo_progress() {
    # This would integrate with TodoRead if available
    # For now, return a placeholder
    echo "Progress tracking will be added when TodoRead is available"
}

# Find current session
CURRENT_SESSION=$(find_current_session "$SESSION_ID")

if [ -n "$CURRENT_SESSION" ]; then
    # Create temporary file for safe editing
    TEMP_FILE=$(mktemp)
    
    # Prepare action type
    ACTION_TYPE="compact-$TRIGGER"
    
    # Update the session log
    awk -v ts="$TIMESTAMP" -v act="$ACTION_TYPE" -v trigger="$TRIGGER" \
        -v instructions="$CUSTOM_INSTRUCTIONS" '
    BEGIN { in_fm = 0; in_progress = 0; in_key = 0 }
    
    # Handle frontmatter
    /^---$/ { 
        if (in_fm == 0) { in_fm = 1; print; next }
        else { in_fm = 0; print; next }
    }
    
    # Update timestamps in frontmatter
    in_fm && /^timestamps:/ {
        print
        # Read existing timestamps
        while (getline && match($0, /^  - /)) {
            print
        }
        # Add new timestamp
        printf "  - {time: \"%s\", action: \"%s\"}\n", ts, act
        if ($0 !~ /^  - /) print
        next
    }
    
    # Update Key Moments section
    /^## Key Moments/ {
        print
        in_key = 1
        next
    }
    
    in_key && /^## / {
        in_key = 0
        # Add progress note before next section
        if (trigger == "manual" && instructions != "") {
            printf "\n- Context compacted (manual): %s\n", instructions
        } else if (trigger == "auto") {
            printf "\n- Context auto-compacted at %s\n", ts
        } else {
            printf "\n- Progress checkpoint at %s\n", ts
        }
    }
    
    # Update Technical Work section
    /^## Technical Work/ {
        print
        in_progress = 1
        next
    }
    
    in_progress && /^## / {
        in_progress = 0
        # Add a progress summary
        printf "\n**Progress as of %s:**\n", ts
        print "- Session ongoing, context compacted (" trigger ")"
        if (instructions != "") {
            print "- Focus: " instructions
        }
        print ""
    }
    
    { print }
    
    END {
        # Handle case where sections might be at end of file
        if (in_key) {
            if (trigger == "manual" && instructions != "") {
                printf "\n- Context compacted (manual): %s\n", instructions
            } else if (trigger == "auto") {
                printf "\n- Context auto-compacted at %s\n", ts
            }
        }
        if (in_progress) {
            printf "\n**Progress as of %s:**\n", ts
            print "- Session ongoing, context compacted (" trigger ")"
            if (instructions != "") {
                print "- Focus: " instructions
            }
        }
    }
    ' "$CURRENT_SESSION" > "$TEMP_FILE"
    
    # Replace original file
    mv "$TEMP_FILE" "$CURRENT_SESSION"
    
    echo "Updated session with $TRIGGER compact at $TIMESTAMP" >&2
else
    echo "Warning: Could not find session with ID $SESSION_ID" >&2
fi

# Output empty JSON to satisfy hook requirements
echo "{}"