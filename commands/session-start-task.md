---
description: Start a session with a specific task
allowed-tools: Read, Edit, LS, Glob, Grep, Bash(date), Bash(tmux), Bash(pwd), Bash(echo), Bash(ls), Bash(wc), Bash(tr), Bash(git branch), Bash(git status), Bash(git worktree), Bash(head), Bash(sed)
---

# Session Start Task

Initialize a new session with specific task context and workspace setup guidance.

## Context

- Current date: !`date +%Y-%m-%d` (the date is in the format `YYYY-MM-DD`)
- Current time: !`date +%H:%M`
- Current working directory: !`pwd`
- Current tmux session: !`tmux display-message -p '#{session_name}' 2>/dev/null || echo "No tmux session"`
- Session folder path: !`echo "/Users/emdash/Grimoire/Journal/Sessions/$(date +%Y/%m/%d)/"`
- Existing session count for today: !`ls -1 "/Users/emdash/Grimoire/Journal/Sessions/$(date +%Y/%m/%d)/" 2>/dev/null | wc -l | tr -d ' '`
- Current git branch: !`git branch --show-current 2>/dev/null || echo "Not in git repository"`
- Current git status: !`git status --porcelain 2>/dev/null | wc -l | tr -d ' '` files changed
- Current git worktree: !`git worktree list --porcelain 2>/dev/null | head -1 | sed 's/worktree //' || echo "No worktree"`

## Instructions

@~/.claude/commands/session-start.md

1. **Find and Load Task**:
   - Use same fuzzy search logic as ~/.claude/commands/task-load.md
   - Search `/Users/emdash/Grimoire/Tasks/**/*.md` (exclude archived and completed)
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
