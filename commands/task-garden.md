---
description: "Garden and maintain tasks with natural language queries and filters"
allowed-tools: ["Bash", "Read", "Edit", "LS", "Glob", "Grep"]
---

# Task Garden

Review, update, and maintain tasks using natural language queries and smart filtering.

## Usage

`/task-garden [natural language query or action]`

Examples:
- `/task-garden` - Show overview dashboard with tag vocabulary
- `/task-garden show blocked tasks`
- `/task-garden what's overdue`
- `/task-garden automattic work`
- `/task-garden update stale items`
- `/task-garden pending tasks by priority`
- `/task-garden tag vocabulary` - Show all existing tags for reuse

## Instructions

1. **Parse Natural Language Query**:
   - **Status filters**: "active", "blocked", "pending", "completed", "draft"
   - **Priority filters**: "high priority", "urgent", "low priority"
   - **Category filters**: "automattic", "personal", specific folder names
   - **Tag filters**: any existing tag name (e.g., "testing tasks", "php work")
   - **Time filters**: "overdue", "stale", "recent", "old"
   - **Action verbs**: "show", "list", "update", "review", "clean"
   - **Special queries**: "dashboard", "overview", "summary", "tag vocabulary"

2. **Default Dashboard (no query)**:
   - Count tasks by status across all categories
   - Show category breakdown with counts
   - **Tag vocabulary overview**: List all existing tags with usage counts
   - List active tasks with last update times
   - Highlight blocked tasks with blocker info
   - Show overdue or stale tasks (no updates in >7 days)
   - Display dependency issues (circular dependencies, missing dependencies)

3. **Status-Based Queries**:
   - **"blocked tasks"**: Show tasks with status="blocked" and blocker info
   - **"active tasks"**: List in-progress work with session context
   - **"pending tasks"**: Show tasks ready to start, ordered by priority
   - **"completed tasks"**: Recent completions, suggest archiving old ones

4. **Category-Based Queries**:
   - **"automattic work"**: Filter to Automattic category and subcategories
   - **"personal projects"**: Filter to Personal category
   - **Category-specific**: Use folder structure to filter
   - Show task distribution within categories

5. **Time-Based Queries**:
   - **"stale tasks"**: No updates in >7 days, suggest review
   - **"overdue"**: Tasks past expected completion (heuristic based on created_at + estimated time)
   - **"recent"**: Tasks created or updated in last 3 days
   - Group by time ranges for overview

6. **Maintenance Actions**:
   - **"update stale items"**: Batch update updated_at timestamps with confirmation
   - **"clean completed"**: Suggest archiving old completed tasks
   - **"check dependencies"**: Validate depends_on/blocks references
   - **"fix metadata"**: Find and repair missing or inconsistent frontmatter
   - **"validate timestamps"**: Check all timestamps are in ISO format
   - **"clean session logs"**: Remove duplicate or invalid session_logs entries
   - **"sync entries"**: Ensure entries arrays are properly populated with today's date
   - **"complete metadata"**: Fill in missing working_directory, branch, tmux_session fields

7. **Priority Analysis**:
   - Show high priority tasks first
   - Identify priority conflicts (blocked high-priority items)
   - Suggest priority adjustments based on dependencies
   - Show priority distribution across categories

8. **Dependency Management**:
   - **Circular dependency detection**: Find A→B→A loops
   - **Missing dependencies**: References to non-existent tasks
   - **Blocking analysis**: Show what's blocking high-priority work
   - **Dependency chains**: Visualize task relationships

9. **Smart Suggestions**:
   - Tasks with no recent progress → suggest status review
   - Completed tasks older than 30 days → suggest archiving
   - Draft tasks older than 7 days → suggest deletion or activation
   - Missing session context → suggest using `/task-load`

10. **Display Formats**:
    - **Table view**: Status, Priority, Name (filename), Tags, Last Updated, Category
    - **Tree view**: Category hierarchy with task counts
    - **Timeline view**: Tasks by last update date
    - **Dependency graph**: Text-based relationship visualization

11. **Bulk Operations** (with confirmation):
    - Update multiple task timestamps
    - Change status for filtered task sets
    - Add tags to category-based selections
    - Archive multiple completed tasks

12. **Tag Management**:
    - **"tag vocabulary"**: Show all existing tags with usage counts for reference
    - **Tag-based filtering**: Support queries like "show testing tasks" or "php work"
    - **Tag consistency**: Highlight tasks using similar but inconsistent tags
    - **Tag suggestions**: When showing task lists, suggest relevant tags for filtering
    - **Tag prominence**: Display tags prominently in all task views for easy scanning

13. **Metadata Gardening Capabilities**:
    - **Timestamp validation**: Check all timestamps are in ISO format
    - **Array consistency**: Ensure all arrays are properly formatted
    - **Missing field detection**: Identify tasks with incomplete metadata
    - **Duplicate cleanup**: Remove duplicate entries in session_logs and entries arrays
    - **Workspace sync**: Update working_directory, branch, tmux_session from current context
    - **Link validation**: Check WikiLink format consistency
    - **Session continuity**: Ensure session_logs array tracks all collaborative sessions
    - **Metadata completeness scoring**: Rate tasks by metadata quality

14. **Search Integration**:
    - Use Grep for content-based searches
    - Combine with metadata filtering
    - Support partial title matching
    - Search across task descriptions and notes

## User Request

$ARGUMENTS