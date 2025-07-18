---
description: Archive cancelled/obsolete tasks while preserving nested folder structure
allowed-tools: Bash, Read, Edit, LS, Glob, Grep
---

# Task Archive

Archive cancelled/obsolete tasks to Tasks/Archived/.

## Context

- Current date: !`date +%Y-%m-%d` (the date is in the format `YYYY-MM-DD`)
- Current time: !`date +%H:%M`
- Current working directory: !`pwd`
- Current tmux session: !`tmux display-message -p '#{session_name}' 2>/dev/null || echo "No tmux session"`
- Current git branch: !`git branch --show-current 2>/dev/null || echo "Not in git repository"`
- Current git worktree: !`git worktree list --porcelain 2>/dev/null | head -1 | sed 's/worktree //' || echo "No worktree"`
- Vault configuration: !`cat ~/.claude/vault.json`
- Tasks path: !`cat ~/.claude/vault.json | jq -r '.tasks_path'`

## Instructions

1. **Search for Task**:
   - Use Glob to find all task files: `!cat ~/.claude/vault.json | jq -r '.tasks_path'/**/*.md`
   - Exclude archived tasks: avoid `!cat ~/.claude/vault.json | jq -r '.tasks_path'/Archived/`
   - Exclude completed tasks: avoid `!cat ~/.claude/vault.json | jq -r '.tasks_path'/Completed/`
   - If specific identifier provided, try exact filename match first
   - Then try fuzzy matching on filenames
   - Finally search content using Grep for broader matches
   - Present top 3-5 matches if multiple found, ask user to clarify

2. **Validate Task Status**:
   - Read task file and check status
   - If task is "completed", suggest using `/task-complete` instead
   - Show task summary before archiving

3. **Update Task Metadata Before Archiving**:
   - Update task frontmatter:
     - `status`: "archived"
     - `updated_at`: Current timestamp in ISO format
     - `completed_at`: Current timestamp in ISO format (if not already set)
     - `session_id`: Current session identifier if in active session
     - `tmux_session`: Current tmux session name (if not already set)
     - `working_directory`: Current working directory (if not already set)
     - `branch`: Current git branch (if not already set)
     - `worktree`: Current git worktree path (if applicable and not already set)
   - Verify and complete missing metadata:
     - Check that all required timestamps are in ISO format
     - Ensure all arrays are properly formatted
     - Validate that entries array includes archival date
     - Confirm session_logs array is populated if sessions occurred
     - Add archival reason to task notes if not obvious
   - Preserve all other metadata and content

4. **Move Task File**:
   - Determine archive location: `!cat ~/.claude/vault.json | jq -r '.tasks_path'/Archived/[category-path]/`
   - Maintain exact folder structure in archive directory
   - Support unlimited nesting depth
   - Preserve file naming and content exactly
   - Create directory structure with `mkdir -p`
   - Use `mv` command to move file to archive location
   - Verify move was successful
   - Check that original file no longer exists
   - Confirm archived file exists and is readable

5. **Update Related Tasks**:
   - Search for tasks that reference this task in:
     - `depends_on` arrays
     - `blocks` arrays
     - `related_to` arrays
   - Update those task files to reflect archived status
   - Use Grep to find references: search for task filename or title
   - Update related tasks' metadata:
     - Update `updated_at` timestamps
     - Remove dependencies on archived task (or mark as cancelled)
     - Update any blocking relationships
     - Add session log references if relevant

6. **Display Summary**:
   - Show original path → archived path
   - Display task name (from filename) and completion date
   - List any related tasks that were updated
   - Provide archive location for future reference

## Additional User Context

$ARGUMENTS
