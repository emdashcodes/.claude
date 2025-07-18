---
description: Start a session with a specific task
allowed-tools: Read, Edit, LS, Glob, Grep, Bash(claude-sysinfo:*), Bash(find:*), Bash(grep:*), Bash(sort:*), Bash(head:*), Bash(tail:*), Bash(wc:*), Bash(cut:*), Bash(awk:*), Bash(sed:*), Bash(xargs:*)
---

# Session Start Task

Initialize a new session with specific task context and workspace setup guidance.

## Context

!`claude-sysinfo session-context`

## Instructions

@~/.claude/commands/session-start.md

1. **Find and Load Task**:
   - Use same fuzzy search logic as ~/.claude/commands/task-load.md
   - Search `!cat ~/.claude/vault.json | jq -r '.tasks_path'/**/*.md` (exclude archived and completed)
   - Present matches if multiple found
   - Load the selected task context and metadata
   - Read any additional linked context files

2. **Update Task Session Context**:
   - Update task frontmatter with comprehensive metadata:
     - `updated_at`: Current timestamp in ISO format
     - `session_id`: Generated session ID
     - `tmux_session`: Current tmux session name
     - `working_directory`: Current working directory (if not already set)
     - `branch`: Current git branch (if not already set)
     - `worktree`: Current git worktree path (if applicable and not already set)
     - If status is "pending" or "draft", suggest changing to "active"
     - Set `started_at` timestamp if status changes to "active" and not already set
     - Add link to today's daily entry: `[[YYYY-MM-DD]]`

3. **Show Next Steps**:
   - Based on progress log, suggest immediate next actions
   - If blocked, highlight what needs to be resolved
   - If dependencies exist, show status of prerequisite tasks
   - Suggest tools or commands for next phase of work
   - Check for ongoing work from previous sessions

## Additional User Context

$ARGUMENTS
