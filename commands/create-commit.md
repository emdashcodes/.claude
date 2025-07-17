---
description: Create a git commit
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git log:*), Bash(git diff:*), Bash(git branch:*), Bash(git status), Bash(git diff), Bash(git branch), Bash(git log)
---

# Create Git Commit

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single git commit. If there are any unstaged changes, add them first.

The commit message should be clear and concise. 75 characters max. The commit should be prefixed with the type of change (e.g., `fix:`, `feature:`, `docs:`, etc.).
