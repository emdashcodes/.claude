---
description: "Add todo items to today's entry Work or Personal sections"
allowed-tools: ["Bash", "Read", "Edit", "Write"]
---

# Vault Todo

Add todo items to today's entry in the Work or Personal sections.

## Usage

`/vault:todo [work|personal] [todo item text]`

## Instructions

1. **Parse Input**:
   - First argument: "work" or "personal" (defaults to "work" if not specified)
   - Remaining text: the todo item content
   - If no todo text provided, show current todos and exit

2. **Get Today's Date and File**:
   - Calculate today's date: `date +%Y-%m-%d`
   - Path: `/Users/emdash/Grimoire/Journal/Entries/YYYY/MM/YYYY-MM-DD.md`
   - Create today's entry if it doesn't exist using Daily Template

3. **Add Todo Item**:
   - Find the appropriate section (## Work or ## Personal)
   - Add new todo in format: `- [ ] [todo item text]`
   - If todo relates to an existing task, add WikiLink: `- [ ] [todo text] ([[Task Name]])`
   - Place after existing todos in that section
   - Maintain proper formatting and spacing

4. **Display Result**:
   - Show the updated section with the new todo highlighted
   - Confirm which section the todo was added to
   - Show file path for easy access

5. **Smart Categorization**:
   - Look for work-related keywords (meeting, PR, code, deploy, etc.) to suggest "work"
   - Look for personal keywords (health, home, family, etc.) to suggest "personal"
   - Check if todo text matches existing task names and suggest WikiLink
   - Ask for confirmation if category is ambiguous

## User Request

$ARGUMENTS