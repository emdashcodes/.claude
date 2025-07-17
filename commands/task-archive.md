---
description: "Archive completed tasks while preserving nested folder structure"
allowed-tools: ["Bash", "Read", "Edit", "LS", "Glob", "Grep"]
---

# Task Archive

Archive cancelled/obsolete tasks to Tasks/Archived/ while maintaining folder hierarchy. For completed tasks, use the Completed folder instead.

## Usage

`/task-archive [natural language task identifier]`

## Instructions

1. **Find Task to Archive**:
   - Use same fuzzy search logic as task-load
   - Search in `/Users/emdash/Grimoire/Tasks/**/*.md`
   - Exclude already archived tasks in `Tasks/Archived/`
   - Exclude already completed tasks in `Tasks/Completed/`
   - Present matches if multiple found

2. **Validate Task Status**:
   - Read task file and check frontmatter status
   - If task is "completed", suggest moving to Completed folder instead: "This task is completed. Use `/task-complete` to move to Completed folder, or continue to archive as cancelled/obsolete?"
   - Show task summary before archiving
   - Ask for explicit confirmation: "Archive '[task-filename]' to archived folder? (y/n)"

3. **Determine Archive Location**:
   - Get current task path relative to Tasks/ root
   - Example: `/Users/emdash/Grimoire/Tasks/Automattic/AI Agents/feature-task.md`
   - Archive path: `/Users/emdash/Grimoire/Tasks/Archived/Automattic/AI Agents/feature-task.md`
   - Preserve full nested directory structure in archive

4. **Create Archive Directory Structure**:
   - Extract directory path from current task location
   - Create nested directories in archive: `mkdir -p /Users/emdash/Grimoire/Tasks/Archived/[category-path]/`
   - Ensure all parent directories exist

5. **Update Task Metadata Before Archiving with Complete Gardening**:
   - Update task frontmatter:
     - `status`: "archived"
     - `updated_at`: Current timestamp in ISO format
     - `completed_at`: Current timestamp in ISO format (if not already set)
     - `session_id`: Current session identifier if in active session
     - `tmux_session`: Current tmux session name (if not already set)
     - `working_directory`: Current working directory (if not already set)
     - `branch`: Current git branch (if not already set)
     - `worktree`: Current git worktree path (if applicable and not already set)
   - Verify and complete missing metadata:
     - Check that all required timestamps are in ISO format
     - Ensure all arrays are properly formatted
     - Validate that entries array includes archival date
     - Confirm session_logs array is populated if sessions occurred
     - Add archival reason to task notes if not obvious
   - Preserve all other metadata and content

6. **Move Task File**:
   - Use `mv` command to move file to archive location
   - Verify move was successful
   - Check that original file no longer exists
   - Confirm archived file exists and is readable

7. **Update Related Tasks with Metadata Gardening**:
   - Search for tasks that reference this task in:
     - `depends_on` arrays
     - `blocks` arrays  
     - `related_to` arrays
   - Update those task files to reflect archived status
   - Use Grep to find references: search for task filename or title
   - Update related tasks' metadata:
     - Update `updated_at` timestamps
     - Remove dependencies on archived task (or mark as cancelled)
     - Update any blocking relationships
     - Add session log references if relevant

8. **Display Archive Summary**:
   - Show original path → archived path
   - Display task name (from filename) and completion date
   - List any related tasks that were updated
   - Provide archive location for future reference
   - Show command to unarchive if needed: suggest manual mv back

9. **Archive Directory Organization**:
   - Maintain exact folder structure: `Tasks/Archived/[original-category-path]/`
   - Support unlimited nesting depth
   - Preserve file naming and content exactly
   - Allow browsing archived tasks by category

10. **Safety Checks**:
    - Verify source file exists before moving
    - Check destination doesn't already exist (prevent overwrites)
    - Validate file permissions
    - Confirm successful move before updating related tasks

## User Request

$ARGUMENTS