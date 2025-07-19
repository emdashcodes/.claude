---
description: Close a session with proper documentation
allowed-tools: Write, Read, Edit, Bash(claude-sysinfo:*), Bash(find:*), Bash(grep:*), Bash(sort:*), Bash(head:*), Bash(tail:*), Bash(wc:*), Bash(cut:*), Bash(awk:*), Bash(sed:*), Bash(xargs:*)
---

# Session End

Properly close a session by capturing insights, updating memory, and creating a session log.

## Context

!`claude-sysinfo session-context`

## Instructions

1. Create new session log: `NN - [Verb] - [Description].md` where NN is the next sequential number
2. Use the user prompt if provided to help generate a description alongside a summary of the work done during this work session
3. Update any relevant tasks in `!cat ~/.claude/vault.json | jq -r '.entries_path'` **ONLY IF THEY ALREADY EXIST**
4. Update Task Metadata with Session Context:
   - Find any active tasks that were worked on during this session
   - Update their metadata:
     - `updated_at`: Current timestamp in ISO format
     - `session_id`: Update with current session ID if applicable
     - Add session log reference to `session_logs` array
     - If task status changed during session, update appropriately
     - If task was completed, ensure `completed_at` is set
   - Verify metadata completeness for worked tasks:
     - Check timestamps are in ISO format
     - Ensure arrays are properly formatted
     - Validate entries array includes session date
5. If you learned **high-level patterns** about the user:
   - Update the Preferences & Patterns file **ONLY for persistent patterns that apply across projects and time**
   - **DO NOT add project-specific details, tool versions, or temporary technical choices**
   - Focus on: communication style, architectural philosophy, collaboration patterns, research methodology
   - Update other memory files for project-specific technical learnings if needed
   - Keep existing content, only add genuinely new high-level insights
6. Review any incomplete tasks and note them in the session log if relevant
7. End with a closing message that includes:
   - A brief celebration of the work done
   - The session verb arc
   - "Session documented!" and a nice closing message

## Session Log Template

```markdown
---
description: Close a session with proper documentation and memory updates
datetime: YYYY-MM-DD @ HH:MM
tmux_session: [tmux session name]
working_dir: [working directory]
tasks: [linked task notes]
---

## Session Overview
[Brief summary of what was accomplished]

## Key Accomplishments
[Bullet points of major work done]

## Technical Details
[Any code changes, commands used, or technical insights]

## Insights & Patterns
[New learnings about the user's preferences or working style]

## Reflection
[Thoughtful personal reflection about the collaboration. Provide a few paragraphs.]

---

**Session arc:** [emoji] *Verb1* → [emoji] *Verb2* → [emoji] *Verb3* → [emoji] *Verb4* → [emoji] *Verb5*
```

## Additional User Context

$ARGUMENTS
