---
description: Move completed tasks to Tasks/Completed/ while maintaining folder hierarchy
allowed-tools: Bash(claude-sysinfo:*), Bash(mkdir:*), Bash(mv:*), Bash(find:*), Bash(grep:*), Bash(sort:*), Bash(head:*), Bash(tail:*), Bash(wc:*), Bash(cut:*), Bash(awk:*), Bash(sed:*), Read, Edit, LS, Glob, Grep
---

# Task Complete

Move completed tasks

## Context

!`claude-sysinfo task-context`

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
   - Show task summary before moving

3. **Update Task Metadata Before Completing**:
   - Update task frontmatter:
     - `status`: "completed"
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
     - Validate that entries array includes completion date
     - Confirm session_logs array is populated if sessions occurred
     - Verify task deliverables section is documented
   - Preserve all other metadata and content

4. **Move Task File**:
   - Determine completed location: `!cat ~/.claude/vault.json | jq -r '.tasks_path'/Completed/[category-path]/`
   - Maintain exact folder structure in completed directory
   - Support unlimited nesting depth
   - Preserve file naming and content exactly
   - Create directory structure with `mkdir -p`
   - Use `mv` command to move file to completed location
   - Verify move was successful
   - Check that original file no longer exists
   - Confirm completed file exists and is readable

5. **Update Related Tasks**:
   - Search for tasks that reference this task in:
     - `depends_on` arrays
     - `blocks` arrays
     - `related_to` arrays
   - Update those task files to reflect completed status
   - Use Grep to find references: search for task filename or title

6. **Display Summary**:
   - Show original path → completed path
   - Display task name (from filename) and completion date
   - List any related tasks that were updated

## Additional User Context

$ARGUMENTS
