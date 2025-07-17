---
description: "Create or open a daily entry in Grimoire with calendar integration"
allowed-tools: Bash(*), Read, Write, LS, Edit, mcp__google-calendar__list-events
---

# Vault Daily Entry

Create or open a daily entry in Grimoire with your standard template.

## Usage

`/vault:day [optional: date like "today", "tomorrow", "yesterday", "+2 days", or "2025-07-15"]`

## Instructions

1. **Calculate Target Date**:
   - If no argument provided, use today's date
   - If argument provided, parse it:
     - "today", "tomorrow", "yesterday" 
     - Relative dates like "+1 day", "+2 days", "-1 day"
     - Specific dates like "2025-07-15"
   - Format as YYYY-MM-DD

2. **Check for Existing Entry**:
   - Path: `/Users/emdash/Grimoire/Journal/Entries/YYYY/MM/YYYY-MM-DD.md`
   - If file exists, read and display current content
   - If file doesn't exist, create it with template

3. **Create Directory if Needed**:
   - Ensure `/Users/emdash/Grimoire/Journal/Entries/YYYY/MM/` exists
   - Create directories if missing

4. **Create Daily Entry**:
   - Use Daily Template from `/Users/emdash/Grimoire/Templates/Daily Template.md`
   - Create file at the correct path
   - Only create if file doesn't exist

5. **Display Entry**:
   - Show the file path for easy access
   - Display current content of the entry
   - Indicate if it was newly created or already existed

6. **Calendar Integration**:
   - Query Google Calendar for events on the target date using `mcp__google-calendar__list-events`
   - Use all calendar IDs: `["ember.shreve@gmail.com", "em.shreve@a8c.com", "7clnu92d7f60k6tftjm21m0clg@group.calendar.google.com", "en.usa#holiday@group.v.calendar.google.com"]`
   - Set timeMin to target date 00:00:00 and timeMax to target date 23:59:59
   - Parse calendar events and add to appropriate sections:
     - Work events (from em.shreve@a8c.com) → Add to "## Work" section as `- [ ] Event Name (time)`
     - Personal events (from other calendars) → Add to "## Personal" section as `- [ ] Event Name (time)`
   - Only add if the daily entry was newly created or if calendar events aren't already present

7. **Optional Quick Add**:
   - If user provides content in the prompt, append it to the Journal section
   - Format as a timestamped entry: `- HH:MM - [user content]`

## Date Calculation Commands (macOS)

Use these bash commands for date calculations:
- Today: `date +%Y-%m-%d`
- Tomorrow: `date -v+1d +%Y-%m-%d`
- Yesterday: `date -v-1d +%Y-%m-%d`
- Add days: `date -v+Nd +%Y-%m-%d` (replace N with number)
- Subtract days: `date -v-Nd +%Y-%m-%d` (replace N with number)
- Parse specific date: `date -j -f "%Y-%m-%d" "2025-07-15" +%Y-%m-%d`
- Current time: `date +%H:%M`
- Parse text dates: For "today", "tomorrow", "yesterday" use direct commands above

## User Request

$ARGUMENTS