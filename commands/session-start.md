---
description: "Begin a new session with context loading"
allowed-tools: ["Read", "LS", "Glob", "Bash"]
---

# Session Start

Initialize a new session by loading relevant context and preparing for a task.

## Usage

`/user:session-start [Potential session focus area or prompt]`

## Instructions

1. **Gather Session Information**: Before starting a new session:
   - Get current date with `date +%Y/%m/%d` to determine the current date. The date is in the format `YYYY/MM/DD`.
   - Get current time with `date +%H:%M` to check the time of day
   - Get current tmux session (if one exists) with `tmux display-message -p '#{session_name}' 2>/dev/null || echo "No tmux session"`

2. **Load Core Memory Context**: Read these essential files from Grimoire:
   - `/Users/emdash/Grimoire/Memory/Em - Preferences & Patterns.md` - Load Em's working style and preferences
   - Check for any project-specific memory files in `/Users/emdash/Grimoire/Memory/` related to the user prompt or the tmux session name

3. **Review Recent Sessions**:
   - List recent journal entries in `/Users/emdash/Grimoire/Journal/Sessions/YYYY/MM/DD/`
   - List recent entries in `/Users/emdash/Grimoire/Journal/Entries/YYYY/MM/`
   - If relevant to the user prompt, briefly scan the most recent 2-3  entries for context
   - Note any ongoing work

4. **Check Active Projects**: If the user prompt mentions a specific project:
   - Look for relevant files in `/Users/emdash/Grimoire/Dev/`
   - Load any project-specific context or documentation

5. **Check Project Documentation**:
   - Look for README.md in the current working directory
   - Check for CLAUDE.md in the current working directory
   - Check parent directory for README.md and CLAUDE.md files
   - Scan main subdirectories (src/, lib/, app/, etc.) for any additional related documentation files
   - Note any project-specific instructions or conventions

6. **Check Active Tasks with Metadata Awareness**: Before concluding session start:
   - Use Glob to scan `/Users/emdash/Grimoire/Tasks/**/*.md` for active tasks (exclude Archived/ and Completed/)
   - Exclude archived tasks in `Tasks/Archived/`
   - Look for tasks with status="active" or recent updates
   - Analyze task metadata quality:
     - Check for tasks with missing or outdated metadata
     - Identify tasks with incomplete session_logs arrays
     - Note tasks with missing timestamps or invalid formats
   - Show task dashboard if active tasks found:
     - Task count by status and category
     - Active tasks with last update times
     - Highlight tasks needing metadata gardening
     - Suggest using `/task-load [task-name]` to continue work
     - Suggest using `/session-start-task [task-name]` for full task context
     - Recommend `/task-garden` for metadata maintenance if needed

7. **Prepare for Session**: After gathering context:
   - Use an appropriate greeting based on the time (good morning, good afternoon, good evening, or late night acknowledgment)
   - Briefly acknowledge what you've learned (1 paragraph max)
   - Mention any relevant ongoing work (including active tasks if found)
   - Show task overview if active tasks exist
   - State readiness to continue

## User Prompt

$ARGUMENTS
