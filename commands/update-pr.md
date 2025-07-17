---
allowed-tools: Bash(git log:*), Bash(git diff:*), Bash(git status:*), Bash(git branch:*), Bash(gh pr list:*), Bash(gh pr view:*), Bash(gh pr edit:*), Bash(gh pr status:*), Bash(git status), Bash(git branch), Bash(git log), Bash(gh pr view)
description: Update an existing PR with recent commits
---

# Update PR Request

Update an existing Pull Request with recent commits and changes that may not be reflected in the current PR description.

## Context

- Current git status: !`git status`
- Current branch: !`git branch --show-current`
- Recent commits (last 10): !`git log --oneline -10`
- All commits on current branch vs main: !`git log --oneline HEAD ^trunk`
- Current PR for this branch: !`gh pr view --json title,body,number,url 2>/dev/null || echo "No PR found for current branch"`

## Your Task

1. **Identify the current PR** for this branch (if any)
2. **Analyze recent commits** to understand what has changed since the PR was created
3. **Update the PR description** to include:
   - Any new functionality or fixes added in recent commits
   - Updated testing instructions if needed
   - Any breaking changes or important notes
4. **Maintain the original PR structure** while incorporating new information

## PR Update Guidelines

- Keep the original PR title unless the scope has significantly changed
- Add new commits to the description in a logical way
- Update testing instructions if new features require different testing
- Preserve any existing discussion context
- Use clear language about what's been added/changed since the original PR

## Fallback

If no PR exists for the current branch, suggest creating one using the create-pr command.
