---
description: Create a new task
allowed-tools: Bash, Read, Write, LS, Glob, Grep
---

# Task New

Create a new task

## Context

- Current date: !`date +%Y-%m-%d` (the date is in the format `YYYY-MM-DD`)
- Current time: !`date +%H:%M`
- Current working directory: !`pwd`
- Current tmux session: !`tmux display-message -p '#{session_name}' 2>/dev/null || echo "No tmux session"`
- Current git branch: !`git branch --show-current 2>/dev/null || echo "Not in git repository"`
- Current git worktree: !`git worktree list --porcelain 2>/dev/null | head -1 | sed 's/worktree //' || echo "No worktree"`
- Tasks path: !`cat ~/.claude/vault.json | jq -r '.tasks_path'`
- Task template: !`cat ~/.claude/vault.json | jq -r '.task_template'`

## Instructions

1. **Look at the user's request**:
   - Extract task title
   - Identify priority (urgent, high, low, etc.)
   - Identify type keywords (bug, feature, research, refactor, etc.)
   - Extract GitHub PR references if provided (PR #123, github.com/org/repo/pull/123, etc.)
   - Extract Linear issue references (LIN-123, linear.app/issue/123, etc.)

2. **Analyze Existing Tags** (before creating new ones):
   - Use Glob to find all existing task files: `!cat ~/.claude/vault.json | jq -r '.tasks_path'/**/*.md`
   - Exclude archived tasks: avoid `!cat ~/.claude/vault.json | jq -r '.tasks_path'/Archived/`
   - Use Grep to extract all existing tags from the YAML frontmatter
   - Build vocabulary of existing tags for consistency
   - Prefer reusing existing tags over creating new ones

3. **Determine Category and Location**:
   - Check inside `!cat ~/.claude/vault.json | jq -r '.tasks_path'`
   - Derive categories from current subfolder structure
   - If no, check for project indicators:
     - Look for WordPress/Automattic indicators → "Automattic"
     - Check tmux session name for category hints
     - Default to "General" if unable to determine
   - Target directory: `!cat ~/.claude/vault.json | jq -r '.tasks_path'/[category]/`

4. **Generate Filename**:
   - Take first 3-6 significant words from title
   - Clean filename. Remove special chars: #, ^, [, ], and |. All other characters (including spaces) are allowed!
   - Ensure filename is unique in target directory
   - Format: `[cleaned-title].md`

5. **Create Task File**:
   - Load template from `!cat ~/.claude/vault.json | jq -r '.task_template'`
   - Populate frontmatter with complete metadata gardening:
     - `tags`: Selected tags
     - `category`: Auto-derived category path
     - `status`: "draft"
     - `priority`: Parsed priority or "medium"
     - `type`: Parsed type or "feature"
     - `created_at`: Current timestamp in ISO format
     - `updated_at`: Current timestamp in ISO format
     - `started_at`: Leave empty (will be set when task becomes active)
     - `completed_at`: Leave empty (will be set when task is completed)
     - `session_id`: Leave empty (will be set when task is first loaded)
     - `tmux_session`: Current tmux session name if available
     - `working_directory`: Current working directory
     - `additional_working_dirs`: Array of any additional relevant directories
     - `branch`: Current git branch if in a git repository
     - `worktree`: Current git worktree path if applicable
     - `depends_on`: Empty array (can be populated later)
     - `blocks`: Empty array (can be populated later)
     - `related_to`: Empty array (can be populated later)
     - `entries`: Array with today's date: `[[YYYY-MM-DD]]`
     - `session_logs`: Empty array (will be populated as sessions are created)
     - `github_prs`: Array of extracted GitHub PR references
     - `linear_issues`: Array of extracted Linear issue references
     - `forgejo_prs`: Empty array (can be populated later)
   - Populate content:
     - Add description to ## Info section
     - Add any URLs/links to ## Context & Background section
     - Generate context-appropriate progress log based on task type:
       - **bug**: Reproduce → Investigate root cause → Implement fix → Test fix → Deploy
       - **feature**: Research/planning → Design → Implementation → Testing → Review → Deploy
       - **research**: Literature review → Analysis → Documentation → Presentation/Report
       - **refactor**: Analysis → Planning → Implementation → Testing → Code review → Deploy
       - **testing**: Test plan → Implementation → Execution → Results analysis → Report
       - **documentation**: Outline → Research → Writing → Review → Publish

6. **Ensure Directory Structure**:
   - Create category directories if they don't exist
   - Use `mkdir -p` for nested category creation

7. **Metadata Verification**:
   - Verify all required frontmatter fields are populated
   - Ensure timestamps are in correct ISO format
   - Validate that arrays are properly formatted
   - Confirm tags are consistent with existing vocabulary

8. **Display Result**:
   - Show the created task to the user
   - Display the populated frontmatter for confirmation
   - Suggest next steps
   - If current working directory differs from task working directory, notify the user

## Additional User Context

$ARGUMENTS
