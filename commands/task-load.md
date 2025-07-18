---
description: Load task context and provide workspace setup guidance
allowed-tools: Bash(claude-sysinfo:*), Bash(find:*), Bash(grep:*), Bash(sort:*), Bash(head:*), Bash(tail:*), Bash(wc:*), Bash(cut:*), Bash(awk:*), Bash(sed:*), Read, Edit, LS, Glob, Grep
---

# Task Load

Load task context

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

2. **Load Task Context**:
   - Read the selected task file
   - Parse frontmatter metadata
   - Extract current status, dependencies, session info
   - Check for blockers and related tasks

3. **Analyze Workspace Requirements**:
   - Compare the provided context with the task requirements:
     - Task working_directory vs current directory
     - Task tmux_session vs current tmux session
     - Task branch vs current branch
     - Task worktree vs current worktree

4. **Provide Setup Guidance**:
   - **NEVER auto-change directories or sessions**
   - **INFORM USER** about needed changes:
     - If different directory needed: "Task workspace: `cd [task-working-directory]`"
     - If different tmux session: "Task tmux session: `tmux attach -t [session-name]`"
     - If different branch: "Task branch: `git checkout [branch-name]`"
     - If different worktree: "Task worktree: `cd [worktree-path]`"
   - Show current vs required workspace setup to the user

5. **Update Task Metadata**:
   - Verify and update task frontmatter:
     - `updated_at`: Current timestamp in ISO format
     - `session_id`: Current session identifier
     - `tmux_session`: Current tmux session name
     - `working_directory`: Current working directory
     - `worktree`: Current git worktree path (if applicable)
     - If status is "pending" or "draft", suggest changing to "active"
     - Set `started_at` timestamp if status changes to "active" and not already set
   - Verify metadata completeness:
     - Check that all required fields are populated
     - Ensure timestamps are in correct ISO format
     - Validate that arrays are properly formatted
     - Confirm entries array includes today's date
   - Add WikiLink to today's daily entry if not already present

6. **Check Related Context**:
   - Check for depends_on tasks and show their status
   - Check for tasks that this blocks
   - Look for related_to tasks in same category
   - Suggest next actions based on progress log

## Additional User Context

$ARGUMENTS
