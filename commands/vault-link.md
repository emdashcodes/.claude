---
description: "Create cross-references between related notes in Grimoire"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep"]
---

# Vault Link

Create cross-references and connections between related notes in your Grimoire vault.

## Usage

`/vault:link [note1] [note2] [optional: relationship description]`

## Instructions

1. **Parse Input**:
   - If no arguments: show recent notes to link interactively
   - If one argument: find similar/related notes to link with
   - If two arguments: create bidirectional links between specified notes
   - Optional third argument: describe the relationship

2. **Find Notes**:
   - Search across Journal/Entries/, Journal/Sessions/, Ada/Memory/, Dev/
   - Use fuzzy matching for note titles
   - Show file paths and brief previews for selection

3. **Create Bidirectional Links**:
   - Add WikiLink `[[filename|display text]]` to both notes
   - Place links in appropriate sections (end of file or dedicated "Related" section)
   - Include relationship context if provided

4. **Link Formats**:
   - Session to Entry: `[[session-file|Session: description]]`
   - Memory to Session: `[[memory-file|Related Memory]]`
   - Entry to Entry: `[[date|Related Entry]]`
   - Custom: Use relationship description as display text

5. **Verification**:
   - Show both files with new links added
   - Confirm link text and placement
   - Report successful bidirectional connection

## User Request

$ARGUMENTS