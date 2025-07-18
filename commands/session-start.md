---
description: Begin a new session
allowed-tools: Read, LS, Glob, Bash(claude-sysinfo:*), Bash(find:*), Bash(grep:*), Bash(sort:*), Bash(head:*), Bash(tail:*), Bash(wc:*), Bash(cut:*), Bash(awk:*), Bash(sed:*), Bash(xargs:*)
---

# Session Start

Initialize a new session by loading relevant context and preparing for a task.

## Context

!`claude-sysinfo session-context`

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
