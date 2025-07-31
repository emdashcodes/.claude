---
description: Create a git commit for Gitea repos
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git log:*), Bash(git diff:*), Bash(git branch:*), Bash(git remote:*), Bash(git status), Bash(git diff), Bash(git branch), Bash(git log)
---

# Create Git Commit (Gitea)

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`
- Remote URLs: !`git remote -v | grep -E "(local|gitea)"`

## Your task

Based on the above changes, create a single git commit. If there are any unstaged changes, add them first.

The commit message should be clear and concise. 75 characters max. The commit should be prefixed with the type of change (e.g., `fix:`, `feat:`, `docs:`, etc.).

After committing, push to the 'local' remote if it exists (your Gitea instance).

## Additional User Context

$ARGUMENTS