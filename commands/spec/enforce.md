---
description: Spec Enforce - Re-enable Workflow Enforcement
allowed-tools: Bash
---

# Spec: Enforce

Re-enable spec workflow enforcement for the current session after it has been disabled with `/spec/vibe`.

## Instructions

When you want to re-enable spec workflow enforcement, run the `spec-enforce` script:

```bash
spec-enforce
```

## What This Does

- Removes the enforcement disable lock file
- Re-enables spec workflow enforcement for future plan approvals
- Does not create new blocking states - only removes the disable lock
- Returns the system to normal enforcement behavior

## When to Use

- After using `/spec/vibe` and wanting to return to strict workflow enforcement
- When switching from exploratory work back to structured spec development
- To ensure future plans will trigger automatic workflow enforcement

## Note

This only removes the disable lock. If you currently have pending plan approval states, those will become active again once enforcement is re-enabled.