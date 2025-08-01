---
description: Show status of all available specs
allowed-tools: Read, Bash
---

# Spec: Status

This command shows the status of all available spec features and their current phase.

## Process

### 1. List Available Specs

Find all spec directories:
!`~/.claude/helpers/list-specs.sh`

### 2. Get Detailed Status

Run the detailed status check:
!`~/.claude/helpers/spec-status-detail.sh`

This will show:
- Plan status (draft, approved, etc.)
- Requirements status (draft, approved, implementing, completed)
- Tasks progress (X/Y completed)

### 3. Display Status Summary

Show a table or list format:

```
Available Specs:
================

wordpress-headless-cms-integration:
  - Plan: approved ✓
  - Requirements: approved ✓
  - Tasks: 5/12 completed (implementing)
  
authentication-system:
  - Plan: draft
  - Requirements: not created
  - Tasks: not created

api-refactor:
  - Plan: approved ✓
  - Requirements: completed ✓
  - Tasks: 12/12 completed ✓
```

## Usage Examples

```
User: Show spec status
Assistant: I'll check the status of all available specs.

[Lists all specs with their current phase and completion status]
```

This gives users a quick overview of:
- What features have specs
- Which phase each spec is in
- Progress on implementation
- What needs attention