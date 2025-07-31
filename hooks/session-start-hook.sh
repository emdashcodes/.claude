#!/bin/bash
# Session Start Hook - Creates or updates session logs in Grimoire

# Debug logging to file
DEBUG_LOG="$HOME/.claude/session-hook-debug.log"
echo "[$(date)] SessionStart hook triggered" >> "$DEBUG_LOG"

# Read input from Claude Code
JSON_DATA=$(cat)

# Log the input
echo "[$(date)] Input JSON: $JSON_DATA" >> "$DEBUG_LOG"

# Extract hook data
HOOK_EVENT=$(echo "$JSON_DATA" | jq -r '.hook_event_name' 2>/dev/null || echo "unknown")
SESSION_ID=$(echo "$JSON_DATA" | jq -r '.session_id' 2>/dev/null || echo "unknown")
# Get current working directory (not provided in hook data)
CWD=$(pwd)
SOURCE=$(echo "$JSON_DATA" | jq -r '.source' 2>/dev/null || echo "unknown")
TRANSCRIPT_PATH=$(echo "$JSON_DATA" | jq -r '.transcript_path' 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
DATE=$(date +%Y-%m-%d)

# Get vault paths
VAULT_CONFIG=$(cat ~/.claude/vault.json)
SESSIONS_PATH=$(echo "$VAULT_CONFIG" | jq -r '.sessions_path')
SESSIONS_PATH="${SESSIONS_PATH/#\~/$HOME}"
TEMPLATE_PATH="${HOME}/.claude/templates/session-log.md"

# Function to populate template
populate_template() {
    local template_file="$1"
    local id="$2"
    local timestamp="$3"
    local action="$4"
    local session_id="$5"
    local tmux_session="$6"
    local cwd="$7"
    
    if [ -f "$template_file" ]; then
        # Read template and create output with substitutions
        awk -v id="$id" -v ts="$timestamp" -v act="$action" \
            -v sid="$session_id" -v tmux="$tmux_session" -v wd="$cwd" '
        BEGIN { in_fm = 0 }
        /^---$/ { 
            if (in_fm == 0) { 
                in_fm = 1
                print
                next
            } else { 
                in_fm = 0
                print
                next
            }
        }
        in_fm && /^id:/ {
            print "id: " id
            next
        }
        in_fm && /^status:/ {
            print "status: active"
            next
        }
        in_fm && /^timestamps:/ {
            print "timestamps:"
            print "  - {time: \"" ts "\", action: \"" act "\"}"
            next
        }
        in_fm && /^session_ids:/ {
            print "session_ids:"
            print "  - \"" sid "\""
            next
        }
        in_fm && /^tmux_sessions:/ {
            print "tmux_sessions:"
            print "  - \"" tmux "\""
            next
        }
        in_fm && /^working_dirs:/ {
            print "working_dirs:"
            print "  - \"" wd "\""
            next
        }
        !in_fm && /^# Title/ {
            print "# " id
            next
        }
        { print }
        ' "$template_file"
    else
        echo "Error: Template not found at $template_file" >&2
        echo "[$(date)] ERROR: Template not found at $template_file" >> "$DEBUG_LOG"
        return 1
    fi
}

# Create today's session directory
TODAY_PATH="$SESSIONS_PATH/$(date +%Y/%m/%d)"
mkdir -p "$TODAY_PATH"

# Get current tmux session
if [ -n "$TMUX" ]; then
    TMUX_SESSION=$(tmux display-message -p '#{session_name}' 2>/dev/null || echo "none")
else
    TMUX_SESSION="none"
fi

# Function to find session by ID
find_session_by_id() {
    local search_id="$1"
    find "$TODAY_PATH" -name "*.md" -type f | while read -r file; do
        if grep -q "session_ids:.*$search_id" "$file" 2>/dev/null; then
            echo "$file"
            return 0
        fi
    done
    return 1
}

# Function to get next sequential ID
get_next_id() {
    local count=$(ls -1 "$TODAY_PATH"/*.md 2>/dev/null | wc -l | tr -d ' ')
    printf "%02d" $((count + 1))
}

# Handle different sources
case "$SOURCE" in
    "startup")
        # Create new session log
        NEXT_ID=$(get_next_id)
        SESSION_FILE="$TODAY_PATH/$NEXT_ID.md"
        
        # Create session log from template
        populate_template "$TEMPLATE_PATH" "$NEXT_ID" "$TIMESTAMP" "startup" "$SESSION_ID" "$TMUX_SESSION" "$CWD" > "$SESSION_FILE"
        
        echo "Created new session log: $SESSION_FILE" >&2
        echo "[$(date)] Created new session log: $SESSION_FILE" >> "$DEBUG_LOG"
        ;;
        
    "resume"|"clear")
        # Find existing session to update
        if [ -n "$SESSION_ID" ] && [ "$SESSION_ID" != "unknown" ]; then
            EXISTING_SESSION=$(find_session_by_id "$SESSION_ID")
            
            if [ -n "$EXISTING_SESSION" ]; then
                # Update existing session
                # Create temporary file for safe editing
                TEMP_FILE=$(mktemp)
                
                # Read and update the frontmatter
                awk -v sid="$SESSION_ID" -v ts="$TIMESTAMP" -v act="$SOURCE" \
                    -v tmux="$TMUX_SESSION" -v wd="$CWD" '
                BEGIN { in_fm = 0; printed_ts = 0; printed_sid = 0; printed_tmux = 0; printed_wd = 0 }
                /^---$/ { 
                    if (in_fm == 0) { in_fm = 1; print; next }
                    else { in_fm = 0; print; next }
                }
                in_fm && /^timestamps:/ {
                    print
                    printed_ts = 1
                    # Read existing timestamps
                    while (getline && match($0, /^  - /)) {
                        print
                    }
                    # Add new timestamp
                    printf "  - {time: \"%s\", action: \"%s\"}\n", ts, act
                    if ($0 !~ /^  - /) print
                    next
                }
                in_fm && /^session_ids:/ {
                    print
                    printed_sid = 1
                    # Read existing session IDs
                    found_sid = 0
                    while (getline && match($0, /^  - /)) {
                        print
                        if (index($0, sid) > 0) found_sid = 1
                    }
                    # Add new session ID if not present
                    if (!found_sid) {
                        printf "  - \"%s\"\n", sid
                    }
                    if ($0 !~ /^  - /) print
                    next
                }
                in_fm && /^tmux_sessions:/ {
                    print
                    printed_tmux = 1
                    # Read existing tmux sessions
                    found_tmux = 0
                    while (getline && match($0, /^  - /)) {
                        print
                        if (index($0, tmux) > 0) found_tmux = 1
                    }
                    # Add new tmux session if not present
                    if (!found_tmux) {
                        printf "  - \"%s\"\n", tmux
                    }
                    if ($0 !~ /^  - /) print
                    next
                }
                in_fm && /^working_dirs:/ {
                    print
                    printed_wd = 1
                    # Read existing working dirs
                    found_wd = 0
                    while (getline && match($0, /^  - /)) {
                        print
                        if (index($0, wd) > 0) found_wd = 1
                    }
                    # Add new working dir if not present
                    if (!found_wd) {
                        printf "  - \"%s\"\n", wd
                    }
                    if ($0 !~ /^  - /) print
                    next
                }
                { print }
                ' "$EXISTING_SESSION" > "$TEMP_FILE"
                
                # Replace original file
                mv "$TEMP_FILE" "$EXISTING_SESSION"
                
                echo "Updated existing session: $EXISTING_SESSION" >&2
            else
                echo "Warning: Could not find session with ID $SESSION_ID, creating new session" >&2
                # Create new session without recursion
                NEXT_ID=$(get_next_id)
                SESSION_FILE="$TODAY_PATH/$NEXT_ID.md"
                
                # Create session log from template
                populate_template "$TEMPLATE_PATH" "$NEXT_ID" "$TIMESTAMP" "$SOURCE" "$SESSION_ID" "$TMUX_SESSION" "$CWD" > "$SESSION_FILE"
                
                echo "Created new session log: $SESSION_FILE" >&2
                echo "[$(date)] Created new session log (fallback): $SESSION_FILE" >> "$DEBUG_LOG"
            fi
        fi
        ;;
        
    *)
        echo "Unknown source: $SOURCE" >&2
        ;;
esac

# Output empty JSON to satisfy hook requirements
echo "{}"