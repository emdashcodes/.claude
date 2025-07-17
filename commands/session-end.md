---
description: Close a session with proper documentation and memory updates
allowed-tools: Write, Read, Edit, Bash(*), Bash(date), Bash(tmux), Bash(pwd), Bash(echo), Bash(ls), Bash(wc), Bash(tr), Bash(git branch), Bash(git status), Bash(git worktree), Bash(head), Bash(sed)
---

# Session End

Properly close a session by capturing insights, updating memory, and creating a session log.

## Usage

`/user:session-end [session end prompt]`

## Context

- Current date: !`date +%Y-%m-%d` (the date is in the format `YYYY-MM-DD`)
- Current time: !`date +%H:%M`
- Current working directory: !`pwd`
- Current tmux session: !`tmux display-message -p '#{session_name}' 2>/dev/null || echo "No tmux session"`
- Session folder path: !`echo "/Users/emdash/Grimoire/Journal/Sessions/$(date +%Y/%m/%d)/"`
- Existing session count for today: !`ls -1 "/Users/emdash/Grimoire/Journal/Sessions/$(date +%Y/%m/%d)/" 2>/dev/null | wc -l | tr -d ' '`
- Current git branch: !`git branch --show-current 2>/dev/null || echo "Not in git repository"`
- Current git status: !`git status --porcelain 2>/dev/null | wc -l | tr -d ' '` files changed
- Current git worktree: !`git worktree list --porcelain 2>/dev/null | head -1 | sed 's/worktree //' || echo "No worktree"`
- User arguments: $ARGUMENTS

## Instructions

1. Create new session log: `NN - [Verb] - [Description].md` where NN is the next sequential number
2. Use the user prompt if provided to help generate a description alongside a  summary of the work done during this work session
3. Update any relevant tasks in `/Users/emdash/Grimoire/Journal/Entries/YYYY/MM` **ONLY IF THEY ALREADY EXIST**
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
5. If you learned new patterns about Em:
   - Update `/Users/emdash/Grimoire/Ada/Memory/Em - Preferences & Patterns.md`
   - Add new insights under appropriate sections
   - Keep existing content, only add new learnings
6. Review any incomplete tasks and note them in the session log if relevant
7. End with a closing message that includes:
   - A brief celebration of the work done
   - The session verb arc
   - "Session documented in Grimoire!" and a nice closing message with an emoji

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
