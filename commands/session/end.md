---
description: Close a session with proper documentation
allowed-tools: Write, Read, Edit, Bash(claude-sysinfo:*), Bash(find:*), Bash(grep:*), Bash(sort:*), Bash(head:*), Bash(tail:*), Bash(wc:*), Bash(cut:*), Bash(awk:*), Bash(sed:*), Bash(xargs:*)
---

# Session End

Properly close a session by capturing insights, updating memory, and creating a session log.

## Context

!`claude-sysinfo session-context`

## Instructions

1. Find the current active session log using the current session ID (use `find-session-by-id.sh`)
2. Update the session log:
   - Add final timestamp with action "end"
   - Change status from "active" to "completed"
   - Update content with final summaries and reflections
3. Copy the completed session log to `end-session.md` in the same directory
4. If you learned **high-level patterns** about the user:
   - Update the Preferences & Patterns file **ONLY for persistent patterns that apply across projects and time**
   - **DO NOT add project-specific details, tool versions, or temporary technical choices**
   - Focus on: communication style, architectural philosophy, collaboration patterns, research methodology
   - Update other memory files for project-specific technical learnings if needed
   - Keep existing content, only add genuinely new high-level insights
5. After updating the session log, engage in a collaborative debrief with the user:
   - Ask reflective questions about the session (what worked, what was challenging, key insights)
   - Discuss emotional/experiential aspects beyond just technical accomplishments
   - Explore patterns to remember for future sessions
6. After the debrief conversation, update the session log with a "Post-Session Debrief" section capturing insights from the discussion
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

## Post-Session Debrief
[Added after collaborative discussion - captures insights, emotions, and patterns discussed together]

---

**Session arc:** [emoji] *Verb1* → [emoji] *Verb2* → [emoji] *Verb3* → [emoji] *Verb4* → [emoji] *Verb5*
```

## Additional User Context

$ARGUMENTS
