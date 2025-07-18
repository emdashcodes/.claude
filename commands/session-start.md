---
description: Begin a new session
allowed-tools: Read, LS, Glob, Bash
---

# Session Start

Initialize a new session by loading relevant context and preparing for a task.

## Context

- Current date: !`date +%Y-%m-%d` (the date is in the format `YYYY-MM-DD`)
- Current time: !`date +%H:%M`
- Current working directory: !`pwd`
- Current tmux session: !`tmux display-message -p '#{session_name}' 2>/dev/null || echo "No tmux session"`
- Vault configuration: !`cat ~/.claude/vault.json`
- Tasks path: !`cat ~/.claude/vault.json | jq -r '.tasks_path'`
- Entries path: !`cat ~/.claude/vault.json | jq -r '.entries_path'`
- Sessions path: !`cat ~/.claude/vault.json | jq -r '.sessions_path'`
- Memory path: !`cat ~/.claude/vault.json | jq -r '.memory_path'`
- Session folder path: !`echo "$(cat ~/.claude/vault.json | jq -r '.sessions_path')/$(date +%Y/%m/%d)/"`
- Existing session count for today: !`ls -1 "$(cat ~/.claude/vault.json | jq -r '.sessions_path')/$(date +%Y/%m/%d)/" 2>/dev/null | wc -l | tr -d ' '`
- Current git branch: !`git branch --show-current 2>/dev/null || echo "Not in git repository"`
- Current git status: !`git status --porcelain 2>/dev/null | wc -l | tr -d ' '` files changed
- Current git worktree: !`git worktree list --porcelain 2>/dev/null | head -1 | sed 's/worktree //' || echo "No worktree"`

## Instructions

1. **Load Core Memory Context**: Read these essential files from vault:
   - Check `!cat ~/.claude/vault.json | jq -r '.memory_path'` for relevant memory files (preferences, etc)
   - Check for any project-specific memory files related to the user prompt or the tmux session name

2. **Review Recent Sessions**:
   - List recent journal entries in `!cat ~/.claude/vault.json | jq -r '.sessions_path'`
   - List recent entries in `!cat ~/.claude/vault.json | jq -r '.entries_path'`
   - If relevant to the user prompt, briefly scan the most recent 2-3  entries for context
   - Note any ongoing work

3. **Check Project Documentation**:
   - Look for README.md in the current working directory
   - Check for CLAUDE.md in the current working directory
   - Check parent directory for README.md and CLAUDE.md files
   - Scan main subdirectories (src/, lib/, app/, etc.) for any additional related documentation files
   - Note any project-specific instructions or conventions

4. **Check Active Tasks**: Before concluding session start:
   - Use Glob to scan `!cat ~/.claude/vault.json | jq -r '.tasks_path'/**/*.md` for active tasks (exclude Archived/ and Completed/)
   - Exclude archived tasks in `Tasks/Archived/`
   - Look for tasks with status="active" or recent updates
   - Analyze task metadata quality:
     - Check for tasks with missing or outdated metadata
     - Identify tasks with incomplete session_logs arrays
     - Note tasks with missing timestamps or invalid formats
   - If active tasks related to the session found:
     - Suggest using `/task-load [task-name]` to continue work

5. **Prepare for Session**: After gathering context:
   - Use an appropriate greeting based on the time (good morning, good afternoon, good evening, or late night acknowledgment)
   - Briefly acknowledge what you've learned (1 paragraph max)
   - Mention any relevant ongoing work related to the context (including active tasks if found)
   - Show related tasks if active tasks exist
   - State readiness to continue

## Additional User Context

$ARGUMENTS
