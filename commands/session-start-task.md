---
description: "Start session with task context loading and workspace setup guidance"
allowed-tools: ["Bash", "Read", "Edit", "LS", "Glob", "Grep"]
---

# Session Start Task

Initialize a new session with specific task context and workspace setup guidance.

## Usage

`/session-start-task [natural language task identifier or description]`

## Instructions

1. **Load Core Session Context** (from existing session-start):
   - Get current date: `date +%Y/%m/%d`
   - Get current time: `date +%H:%M`
   - Get current tmux session: `tmux display-message -p '#{session_name}' 2>/dev/null || echo "No tmux session"`
   - Read core memory: `/Users/emdash/Grimoire/Ada/Memory/Em - Preferences & Patterns.md`

2. **Find and Load Task**:
   - Use same fuzzy search logic as `/task-load`
   - Search `/Users/emdash/Grimoire/Tasks/**/*.md` (exclude archived and completed)
   - Present matches if multiple found
   - Load selected task context and metadata

3. **Analyze Workspace Requirements**:
   - Compare current environment with task requirements:
     - Current directory vs task working_directory
     - Current tmux session vs task tmux_session  
     - Current git branch vs task branch
     - Current git worktree vs task worktree
   - Identify gaps between current and required workspace setup

4. **Present Comprehensive Setup Guide**:
   - **Session greeting** based on time of day
   - **Task overview**: name (from filename), tags, status, priority, category, last update
   - **Workspace setup checklist**:
     ```
     📋 Workspace Setup for: [Task Name from filename]
     
     Directory: 
     Current: [current-dir]
     Required: [task-working-dir]
     Action: cd [task-working-dir]
     
     Tmux Session:
     Current: [current-session] 
     Required: [task-session]
     Action: tmux attach -t [task-session]
     
     Git Branch:
     Current: [current-branch]
     Required: [task-branch] 
     Action: git checkout [task-branch]
     ```

5. **Update Task Session Context with Complete Metadata Gardening**:
   - Generate session ID (timestamp-based)
   - Update task frontmatter with comprehensive metadata:
     - `updated_at`: Current timestamp in ISO format
     - `session_id`: Generated session ID
     - `tmux_session`: Current tmux session name
     - `working_directory`: Current working directory (if not already set)
     - `branch`: Current git branch (if not already set)
     - `worktree`: Current git worktree path (if applicable and not already set)
     - If status is "pending" or "draft", suggest changing to "active"
     - Set `started_at` timestamp if status changes to "active" and not already set
   - Verify and complete missing metadata:
     - Check that all required timestamps are in ISO format
     - Ensure all arrays are properly formatted
     - Validate that entries array includes today's date
     - Confirm session_logs array is initialized (empty if no prior sessions)
     - Verify additional_working_dirs is populated if multiple directories needed
   - Create WikiLinks:
     - Add link to today's daily entry: `[[YYYY-MM-DD]]`, removing comments when added
     - Suggest creating session log with task reference: `[[Task Name]]`

6. **Display Task Dashboard**:
   - **Progress overview**: Show completed/remaining items from progress log
   - **Blockers & dependencies**: Highlight anything blocking progress
   - **Recent session notes**: Show last session's work and discoveries
   - **Related context**: GitHub PRs, Linear issues, related tasks

7. **Show Next Steps**:
   - Based on progress log, suggest immediate next actions
   - If blocked, highlight what needs to be resolved
   - If dependencies exist, show status of prerequisite tasks
   - Suggest tools or commands for next phase of work

8. **Context Continuity**:
   - Check for ongoing work from previous sessions
   - Load any relevant project documentation
   - Check for CLAUDE.md in task working directory
   - Note any recent related sessions or memory updates

9. **Ready State Confirmation**:
   - Confirm Ada has loaded all necessary context
   - State readiness to continue task work
   - Remind about using `/task-garden` for task overview
   - Suggest `/task-archive` when task is completed

10. **Integration with Daily Planning**:
    - Check if task appears in today's daily entry
    - Suggest adding to daily Work section if not present
    - Cross-reference with calendar events if work-related

## User Request

$ARGUMENTS
