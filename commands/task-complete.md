---
description: "Move completed tasks to Tasks/Completed/ while maintaining folder hierarchy"
allowed-tools: Bash(*), Read, Edit, LS, Glob, Grep
---

# Task Complete

Move successfully completed tasks to Tasks/Completed/ while maintaining folder hierarchy.

## Usage

`/task-complete [natural language task identifier]`

## Instructions

1. **Find Task to Complete**:
   - Use same fuzzy search logic as task-load
   - Search in `/Users/emdash/Grimoire/Tasks/**/*.md`
   - Exclude already archived tasks in `Tasks/Archived/`
   - Exclude already completed tasks in `Tasks/Completed/`
   - Present matches if multiple found

2. **Validate Task Status**:
   - Read task file and check frontmatter status
   - Confirm task is "completed" or ask user for confirmation if not
   - Show task summary before moving
   - Ask for explicit confirmation: "Move '[task-filename]' to completed folder? (y/n)"

3. **Determine Completed Location**:
   - Get current task path relative to Tasks/ root
   - Example: `/Users/emdash/Grimoire/Tasks/Automattic/AI Agents/feature-task.md`
   - Completed path: `/Users/emdash/Grimoire/Tasks/Completed/Automattic/AI Agents/feature-task.md`
   - Preserve full nested directory structure in completed folder

4. **Create Completed Directory Structure**:
   - Extract directory path from current task location
   - Create nested directories in completed: `mkdir -p /Users/emdash/Grimoire/Tasks/Completed/[category-path]/`
   - Ensure all parent directories exist

5. **Update Task Metadata Before Moving with Complete Gardening**:
   - Update task frontmatter:
     - `status`: "completed"
     - `updated_at`: Current timestamp in ISO format
     - `completed_at`: Current timestamp in ISO format (if not already set)
     - `session_id`: Current session identifier if in active session
     - `tmux_session`: Current tmux session name (if not already set)
     - `working_directory`: Current working directory (if not already set)
     - `branch`: Current git branch (if not already set)
     - `worktree`: Current git worktree path (if applicable and not already set)
     - `github_prs`: Add any additional PR information
     - `linear_issues`: Add any additional Linear issue references
     - `forgejo_prs`: Add any additional Forgejo PR references
   - Verify all metadata fields are properly filled in:
     - Check that all required timestamps are in ISO format
     - Ensure all arrays are properly formatted
     - Validate that entries array includes completion date
     - Confirm session_logs array is populated if sessions occurred
     - Verify task deliverables section is documented
   - Preserve all other metadata and content

6. **Move Task File**:
   - Use `mv` command to move file to completed location
   - Verify move was successful
   - Check that original file no longer exists
   - Confirm completed file exists and is readable

7. **Update Related Tasks with Session Context**:
   - Search for tasks that reference this task in:
     - `depends_on` arrays
     - `blocks` arrays  
     - `related_to` arrays
   - Update those task files to reflect completed status
   - Use Grep to find references: search for task filename or title
   - Update related tasks' metadata:
     - Update `updated_at` timestamps
     - If session logs exist, add session log references to related tasks' `session_logs` arrays
     - Update any blocking relationships (remove this task from blockers)
     - Add completion notes to related tasks if relevant

8. **Display Completion Summary**:
   - Show original path → completed path
   - Display task name (from filename) and completion date
   - List any related tasks that were updated
   - Provide completed location for future reference
   - Show command to view completed tasks: suggest browsing Tasks/Completed/

9. **Completed Directory Organization**:
   - Maintain exact folder structure: `Tasks/Completed/[original-category-path]/`
   - Support unlimited nesting depth
   - Preserve file naming and content exactly
   - Allow browsing completed tasks by category

10. **Safety Checks**:
    - Verify source file exists before moving
    - Check destination doesn't already exist (prevent overwrites)
    - Validate file permissions
    - Confirm successful move before updating related tasks

## User Request

$ARGUMENTS
