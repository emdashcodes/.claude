---
description: "Create a new task with natural language description and auto-categorization"
allowed-tools: ["Bash", "Read", "Write", "LS", "Glob"]
---

# Task New

Create a new task file with enhanced metadata and natural language parsing.

## Usage

`/task-new [natural language description and context]`

## Instructions

1. **Parse Natural Language Input**:
   - Extract task title from first part of description
   - Identify priority keywords (urgent, high, low, etc.) - default to "medium"
   - Identify type keywords (bug, feature, research, refactor, etc.) - default to "feature"
   - Extract GitHub PR references (PR #123, github.com/org/repo/pull/123, etc.)
   - Extract Linear issue references (LIN-123, linear.app/issue/123, etc.)
   - Preserve remaining context for task description

2. **Analyze Existing Tags** (before creating new ones):
   - Use Glob to find all existing task files: `/Users/emdash/Grimoire/Tasks/**/*.md`
   - Exclude archived tasks: avoid `/Users/emdash/Grimoire/Tasks/Archived/`
   - Use Grep to extract all existing tags from frontmatter: search for `^  - ` in YAML
   - Build vocabulary of existing tags for consistency
   - Prefer reusing existing tags over creating new ones

3. **Determine Category and Location**:
   - Get current working directory: `pwd`
   - Check if inside `/Users/emdash/Grimoire/Tasks/` structure
   - If yes, derive category from current subfolder structure
   - If no, check for project indicators:
     - Look for WordPress/Automattic indicators → "Automattic"
     - Check tmux session name for category hints
     - Default to "General" if unable to determine
   - Target directory: `/Users/emdash/Grimoire/Tasks/[category]/`

4. **Generate Filename**:
   - Take first 3-6 significant words from title
   - Clean filename. Remove special chars: #, ^, [, ], and |. All other characters (including spaces) are allowed!
   - Ensure filename is unique in target directory
   - Format: `[cleaned-title].md`

5. **Create Task File**:
   - Load template from `/Users/emdash/Grimoire/Templates/Task.md`
   - Populate frontmatter with complete metadata gardening:
     - `tags`: Intelligently select tags based on:
       * Existing tag vocabulary (prefer reusing over creating new)
       * Task description keywords and context
       * Category-specific common tags
       * Technology and tool references
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
     - `entries`: Array with today's date: `["[[YYYY-MM-DD]]"]`
     - `session_logs`: Empty array (will be populated as sessions are created)
     - `github_prs`: Array of extracted GitHub PR references
     - `linear_issues`: Array of extracted Linear issue references
     - `forgejo_prs`: Empty array (can be populated later)
   - Populate content:
     - Add description to ## Info section
     - Add any URLs/links to ## Context & Background section
     - Generate context-appropriate progress log based on task type:
       * **bug**: Reproduce → Investigate root cause → Implement fix → Test fix → Deploy
       * **feature**: Research/planning → Design → Implementation → Testing → Review → Deploy
       * **research**: Literature review → Analysis → Documentation → Presentation/Report
       * **refactor**: Analysis → Planning → Implementation → Testing → Code review → Deploy
       * **testing**: Test plan → Implementation → Execution → Results analysis → Report
       * **documentation**: Outline → Research → Writing → Review → Publish
     - Add WikiLink to today's daily entry: `Related: [[YYYY-MM-DD]]`
     - Populate frontmatter entries field with today's date: `- "[[YYYY-MM-DD]]"`
     - Leave other sections as template placeholders

6. **Ensure Directory Structure**:
   - Create category directories if they don't exist
   - Use `mkdir -p` for nested category creation

7. **Metadata Verification**:
   - Verify all required frontmatter fields are populated
   - Ensure timestamps are in correct ISO format
   - Validate that arrays are properly formatted
   - Check that category path exists and is valid
   - Confirm tags are consistent with existing vocabulary

8. **Display Result**:
   - Show the created file path
   - Display the populated frontmatter for confirmation
   - Show next steps: suggest using `/task-load` to start working on it
   - If working directory differs from task category, suggest appropriate `cd` command

9. **Smart Categorization Logic**:
   - Look for Automattic/WordPress keywords → "Automattic"
   - Look for personal project names → "Personal/[project]"
   - Check git remote URLs for category hints
   - Use tmux session names as category indicators

## User Request

$ARGUMENTS
