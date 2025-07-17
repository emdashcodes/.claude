---
description: "Create quick notes in Grimoire Inbox with timestamp"
allowed-tools: Bash(*), Write, Read, LS
---

# Vault Note

Create quick timestamped notes in your Grimoire Inbox for later processing.

## Usage

`/vault:note [note content]`

## Instructions

1. **Generate Timestamp and Filename**:
   - Get current date and time: `date +"%Y-%m-%d %H:%M"`
   - Create filename: `YYYY-MM-DD-HHMM - [first few words].md`
   - Sanitize filename (replace spaces, special chars)

2. **Create Note File**:
   - Path: `/Users/emdash/Grimoire/Inbox/YYYY-MM-DD-HHMM - [preview].md`
   - Ensure Inbox directory exists
   - Use first 3-4 words of content for filename preview

3. **Note Format**:
   ```markdown
   # Quick Note
   *YYYY-MM-DD @ HH:MM*
   
   [note content]
   
   ---
   *Created via /vault:note*
   ```

4. **Smart Processing**:
   - If content mentions dates, add to filename context
   - If content looks like a todo, suggest using `/vault:todo` instead
   - If content is work-related, mention it could go in Automattic/ later

5. **Display Result**:
   - Show the created file path
   - Display the note content for confirmation
   - Suggest next steps (move to appropriate folder, expand, etc.)

6. **Inbox Management**:
   - If Inbox has more than 10 files, suggest cleanup
   - Show count of inbox items after creation

## User Request

$ARGUMENTS