---
description: "Load task context and provide workspace setup guidance"
allowed-tools: Bash(*), Read, Edit, LS, Glob, Grep
---

# Task Load

Load task context with fuzzy search and provide workspace setup guidance.

## Usage

`/task-load [natural language task identifier or description]`

## Instructions

1. **Search for Task**:
   - Use Glob to find all task files: `/Users/emdash/Grimoire/Tasks/**/*.md`
   - Exclude archived tasks: avoid `/Users/emdash/Grimoire/Tasks/Archived/`
   - Exclude completed tasks: avoid `/Users/emdash/Grimoire/Tasks/Completed/`
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
   - Get current working directory: `pwd`
   - Get current tmux session: `tmux display-message -p '#{session_name}' 2>/dev/null || echo "No tmux session"`
   - Get current git branch: `git branch --show-current 2>/dev/null || echo "No git repo"`
   - Get current git worktree: `git worktree list 2>/dev/null | grep $(pwd) || echo "Standard repo"`
   - Compare with task requirements:
     - Task working_directory vs current directory
     - Task tmux_session vs current tmux session
     - Task branch vs current branch
     - Task worktree vs current worktree

4. **Provide Setup Guidance**:
   - **NEVER auto-change directories or sessions**
   - **INFORM USER** about needed changes:
     - If different directory needed: "💡 Task workspace: `cd [task-working-directory]`"
     - If different tmux session: "💡 Task tmux session: `tmux attach -t [session-name]`"
     - If different branch: "💡 Task branch: `git checkout [branch-name]`"
     - If different worktree: "💡 Task worktree: `cd [worktree-path]`"
   - Show current vs required workspace setup in table format

5. **Update Task Metadata with Gardening**:
   - Get current session ID: generate UUID or use timestamp
   - Verify and update task frontmatter:
     - `updated_at`: Current timestamp in ISO format
     - `session_id`: Current session identifier
     - `tmux_session`: Current tmux session name
     - `working_directory`: Current working directory (if not set)
     - `branch`: Current git branch (if not set)
     - `worktree`: Current git worktree path (if applicable)
     - If status is "pending" or "draft", suggest changing to "active"
     - Set `started_at` timestamp if status changes to "active" and not already set
   - Verify metadata completeness:
     - Check that all required fields are populated
     - Ensure timestamps are in correct ISO format
     - Validate that arrays are properly formatted
     - Confirm entries array includes today's date
   - Add WikiLink to today's daily entry if not already present, removing comments
   - Suggest creating session log entry with WikiLink back to task

6. **Display Task Dashboard**:
   - Show task name (from filename), tags, status, priority, category
   - Display progress log with checkboxes
   - Show blockers and dependencies
   - List related tasks if any
   - Display recent session notes
   - Show GitHub PRs and Linear issues if present

7. **Show Related Context**:
   - Check for depends_on tasks and show their status
   - Check for tasks that this blocks
   - Look for related_to tasks in same category
   - Suggest next actions based on progress log

8. **Fuzzy Search Logic**:
   - Try exact filename match (without .md extension)
   - Try partial filename match
   - Search tags in frontmatter for keyword matches
   - Search content for keywords
   - Rank by relevance: exact > filename > tags > content

## User Request

$ARGUMENTS