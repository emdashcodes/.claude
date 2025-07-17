---
description: "Add WikiLinks between tasks, daily entries, and session logs"
allowed-tools: ["Bash", "Read", "Edit", "LS", "Glob", "Grep"]
---

# Task Link

Add WikiLinks to connect tasks with daily entries and session logs.

## Usage

`/task-link [task-name] [entry|session] [target]`

Examples:
- `/task-link agenttic ui entry 2025-07-14`
- `/task-link todo tool session "02 - Task Management Setup"`

## Instructions

1. **Find Target Task**:
   - Use fuzzy search to find task file
   - Load task content to check current links

2. **Verify and Update Task Metadata**:
   - Check task metadata completeness before adding links
   - Update `updated_at` timestamp when adding links
   - Verify all arrays are properly formatted
   - Ensure existing timestamps are in ISO format

3. **Add Entry Link**:
   - Add to frontmatter entries field: `- "[[YYYY-MM-DD]]"`
   - Maintain chronological order
   - Remove any duplicate entries
   - Validate date format consistency

4. **Add Session Link**:
   - Add to frontmatter session_logs field: `- "[[YYYY-MM-DD]] - [[Session Description]]"`
   - Maintain chronological order (newest first)
   - Remove any duplicate session references
   - Validate link format consistency

5. **Bidirectional Linking**:
   - When linking task to entry, offer to add task link to daily entry
   - When linking task to session, offer to add task link to session log
   - Maintain metadata consistency across all linked files

## User Request

$ARGUMENTS