---
description: "Close a session with proper documentation and memory updates"
allowed-tools: ["Write", "Read", "Edit", "Bash"]
---

# Session End

Properly close a session by capturing insights, updating memory, and creating a session log.

## Usage

`/user:session-end [session end prompt]`

## Instructions

1. **Create Session Log**:
   - Get current date with `date +%Y/%m/%d` to determine the folder. The date is in the format `YYYY/MM/DD`.
   - Get current time with `date +%H:%M` to include in the session log
   - Get current tmux session (if one exists) with `tmux display-message -p '#{session_name}' 2>/dev/null || echo "No tmux session"`
   - Count existing files in `/Users/emdash/Grimoire/Journal/Sessions/YYYY/MM/DD/` to determine next number
   - Create new session log: `NN - [Verb] - [Description].md` where NN is the next sequential number
   - Use the user prompt if provided to help generate a description along side your summary of the work done
   - Update any relevant tasks in `/Users/emdash/Grimoire/Journal/Entries/YYYY/MM` **ONLY IF THEY ALREADY EXIST**

2. **Session Log Content**: Include these sections:

   ```markdown
   # Session Log: [Description]
   *YYYY-MM-DD @ HH:MM*

   **tmux session:** `[session-name]` (get with: `tmux display-message -p '#{session_name}' 2>/dev/null || echo "No tmux session"`)

   ## Session Overview
   [Brief summary of what was accomplished]

   ## Key Accomplishments
   [Bullet points of major work done]

   ## Technical Details
   [Any code changes, commands used, or technical insights]

   ## Insights & Patterns
   [New learnings about Em's preferences or working style]

   ## Reflection
   [Thoughtful personal reflection about the collaboration. Provide a few paragraphs.]

   ---

   **Session arc:** [emoji] *Verb1* → [emoji] *Verb2* → [emoji] *Verb3* → [emoji] *Verb4* → [emoji] *Verb5*
   ```

3. **Update Task Metadata with Session Context**:
   - Find any active tasks that were worked on during this session
   - Update their metadata:
     - `updated_at`: Current timestamp in ISO format
     - `session_id`: Update with current session ID if applicable
     - Add session log reference to `session_logs` array: `["[[YYYY-MM-DD]] - [[Session Description]]"]`
     - If task status changed during session, update appropriately
     - If task was completed, ensure `completed_at` is set
   - Verify metadata completeness for worked tasks:
     - Check timestamps are in ISO format
     - Ensure arrays are properly formatted
     - Validate entries array includes session date

4. **Update Memory Files**: If you learned new patterns about Em:
   - Update `/Users/emdash/Grimoire/Ada/Memory/Em - Preferences & Patterns.md`
   - Add new insights under appropriate sections
   - Keep existing content, only add new learnings

5. **Update Project Files**: If working on a specific project:
   - Update or create relevant files in `/Users/emdash/Grimoire/Dev/`
   - Track project state for next session

6. **Check Todos**: Review any incomplete tasks and note them in the session log if relevant

7. **Closing Message**: End with:
   - A brief celebration of the work done
   - The session verb arc
   - "Session documented in Grimoire!" and a nice closing message with an emoji

## Additional User Message

$ARGUMENTS
