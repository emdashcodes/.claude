---
description: Spec Vibe Check - Disable Workflow Enforcement
allowed-tools: Bash
---

# Spec: Vibe Check

Temporarily disable spec workflow enforcement for the current session to allow free exploration and experimentation without being blocked by pending spec requirements.

## Instructions

When you want to disable spec workflow enforcement for the current session, run the `spec-vibe` script:

```bash
spec-vibe
```

## What This Does

- Disables spec workflow enforcement for the current session only
- Removes any pending plan approval state files
- Allows normal tool usage without spec workflow blocking
- Does not affect the actual spec files or workflow - just the enforcement

## When to Use

- When you need to explore the codebase after creating a plan
- For debugging or investigation tasks
- When working on unrelated tasks while a spec is pending
- During development where strict workflow enforcement isn't needed

## Note

This only affects enforcement, not the actual spec workflow. Your plans and requirements remain intact - you're just choosing to bypass the automatic workflow enforcement for this session.
