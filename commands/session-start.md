---
description: Begin a new session
allowed-tools: Read, LS, Glob, Bash(date), Bash(tmux), Bash(pwd), Bash(echo), Bash(ls), Bash(wc), Bash(tr), Bash(git branch), Bash(git status), Bash(git worktree), Bash(head), Bash(sed)
---

# Session Start

Initialize a new session by loading relevant context and preparing for a task.

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

1. **Load Core Memory Context**: Read these essential files from Grimoire:
   - `/Users/emdash/Grimoire/Memory/Em - Preferences & Patterns.md` - Load Em's working style and preferences
   - Check for any project-specific memory files in `/Users/emdash/Grimoire/Memory/` related to the user prompt or the tmux session name

2. **Review Recent Sessions**:
   - List recent journal entries in `/Users/emdash/Grimoire/Journal/Sessions/YYYY/MM/DD/`
   - List recent entries in `/Users/emdash/Grimoire/Journal/Entries/YYYY/MM/`
   - If relevant to the user prompt, briefly scan the most recent 2-3  entries for context
   - Note any ongoing work

3. **Check Project Documentation**:
   - Look for README.md in the current working directory
   - Check for CLAUDE.md in the current working directory
   - Check parent directory for README.md and CLAUDE.md files
   - Scan main subdirectories (src/, lib/, app/, etc.) for any additional related documentation files
   - Note any project-specific instructions or conventions

4. **Check Active Tasks**: Before concluding session start:
   - Use Glob to scan `/Users/emdash/Grimoire/Tasks/**/*.md` for active tasks (exclude Archived/ and Completed/)
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
