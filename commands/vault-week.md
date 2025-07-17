---
description: "Create weekly entry structure with daily entries for the week, including calendar integration"
allowed-tools: Bash(*), Read, Write, LS, Edit, mcp__google-calendar__list-events
---

# Vault Week Setup

Create a weekly planning entry and all daily entries for the upcoming week in Grimoire.

## Usage

`/vault:week [optional: date offset like "+1 week" or specific date like "2025-07-20"]`

## Instructions

1. **Calculate Week Dates**:
   - If no argument provided, use the upcoming Sunday as week start
   - If argument provided, parse it as date offset or specific date
   - Calculate the Monday-Sunday dates for the target week
   - Get ISO week number for the year

2. **Create Weekly Planning File**:
   - Path: `/Users/emdash/Grimoire/Journal/Entries/YYYY/MM/YYYY-W## (Week of MMM D).md`
   - Use the Weekly Template from `/Users/emdash/Grimoire/Templates/Weekly Template.md`
   - Replace placeholders:
     - `W00` → actual week number (e.g., `W29`)
     - `Month DD-DD` → actual date range (e.g., `July 14-20`)
     - `2025-00-00` → actual dates for each day
     - Update daily links with correct dates and day names

3. **Create Daily Entries**:
   - For each day (Monday through Sunday):
   - Path: `/Users/emdash/Grimoire/Journal/Entries/YYYY/MM/YYYY-MM-DD.md`
   - Use Daily Template from `/Users/emdash/Grimoire/Templates/Daily Template.md`
   - Only create files that don't already exist
   - Check if directory exists, create if needed

4. **Verification**:
   - List created files to confirm success
   - Show the weekly file path for easy access
   - Report any files that already existed (skipped)

5. **Calendar Integration**:
   - Query Google Calendar for events during the target week using `mcp__google-calendar__list-events`
   - Use all calendar IDs: `["ember.shreve@gmail.com", "em.shreve@a8c.com", "7clnu92d7f60k6tftjm21m0clg@group.calendar.google.com", "en.usa#holiday@group.v.calendar.google.com"]`
   - Set timeMin to Monday 00:00:00 and timeMax to Sunday 23:59:59 of target week
   - Parse calendar events and categorize:
     - Work events (from em.shreve@a8c.com) → Add to "Work Focus" section
     - Personal events (from other calendars) → Add to "Personal Goals" section
   - Update weekly planning file with calendar events
   - Update individual daily entries with their respective calendar events

6. **Output Summary**:
   - Show week range and file paths created
   - Display the weekly planning file content for review
   - List calendar events integrated
   - Provide next steps if desired

## Date Calculation Commands (macOS)

Use these bash commands for date calculations:
- Current date: `date +%Y-%m-%d`
- Next Sunday: `date -v+sunday +%Y-%m-%d`
- Week number: `date -j -f "%Y-%m-%d" "YYYY-MM-DD" +%V`
- Day of week: `date -j -f "%Y-%m-%d" "YYYY-MM-DD" +%A`
- Add days: `date -j -v+Nd -f "%Y-%m-%d" "YYYY-MM-DD" +%Y-%m-%d`
- Subtract days: `date -j -v-Nd -f "%Y-%m-%d" "YYYY-MM-DD" +%Y-%m-%d`
- Parse relative: `date -v+1w +%Y-%m-%d` (next week), `date -v-1w +%Y-%m-%d` (last week)
- Find Monday of week: `date -j -f "%Y-%m-%d" "YYYY-MM-DD" +%u` then adjust

## User Request

$ARGUMENTS