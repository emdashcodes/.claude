---
description: Add Gitea remote to existing GitHub repository
allowed-tools: Bash(git remote:*), Bash(git config:*), Bash(tea repos:*), Bash(tea repo create:*), Bash(git push:*)
---

# Setup Gitea Remote

Add a Gitea (local) remote to an existing repository that already has a GitHub origin.

## Context

- Current remotes: !`git remote -v`
- Current branch: !`git branch --show-current`
- Repository name: !`basename $(git rev-parse --show-toplevel)`

## Process

1. **Verify existing setup**:
   - Check that we're in a git repository
   - Confirm GitHub remote exists
   - Extract repository name and owner

2. **Check if Gitea repo exists**:
   - Use `tea repos search` to check if repo already exists on Gitea
   - If not, create it with `tea repo create`

3. **Add Gitea remote**:
   - Add remote named "local" pointing to git.hollow.dev
   - Format: `git@git.hollow.dev:emdash/<repo-name>.git`

4. **Initial push** (optional):
   - Push current branch to establish tracking
   - Set up trunk branch if needed

## Additional User Context

$ARGUMENTS