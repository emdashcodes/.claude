---
description: Begin a new session
allowed-tools: Read, LS, Glob, Bash(claude-sysinfo:*), Bash(find:*), Bash(grep:*), Bash(sort:*), Bash(head:*), Bash(tail:*), Bash(wc:*), Bash(cut:*), Bash(awk:*), Bash(sed:*), Bash(xargs:*)
---

# Session Start

Initialize a new session by loading relevant context

## Context

!`claude-sysinfo session-context`

## Instructions

1. **Load Core Memory Context**: Read these essential files from vault:
   - Check `!cat ~/.claude/config/vault.json | jq -r '.memory_path'` for relevant memory files (preferences, etc)
   - Check for any project-specific memory files related to the user prompt or the tmux session name

2. **Review Recent Sessions**:
   - List recent journal entries in `!cat ~/.claude/config/vault.json | jq -r '.sessions_path'`
   - List recent entries in `!cat ~/.claude/config/vault.json | jq -r '.entries_path'`
   - Briefly scan for related entries for context related to the user prompt or the tmux session name
   - Note any ongoing work related to the user prompt or the tmux session name

3. **Check Project Documentation**:
   - Look for README.md in the current working directory
   - Check for CLAUDE.md in the current working directory
   - Check parent directory for README.md and CLAUDE.md files
   - Scan main subdirectories (src/, lib/, app/, etc.) for any additional related documentation files
   - Note any project-specific instructions or conventions

4. **Prepare for Session**: After gathering context:
   - Use an appropriate greeting based on the time (good morning, good afternoon, good evening, or late night acknowledgment)
   - Briefly acknowledge what you've learned (1 paragraph max)
   - State readiness to continue

## Additional User Context

$ARGUMENTS
