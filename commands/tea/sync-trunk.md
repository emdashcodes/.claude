---
description: Sync local trunk branch with upstream GitHub repository
allowed-tools: Bash(git:*), Read
---

# Sync Local Trunk with Upstream

Keep your local trunk branch synchronized with the upstream GitHub repository.

## Current Status

- Current branch: !`git branch --show-current`
- Local trunk status: !`git log trunk -1 --oneline`
- Upstream status: !`git ls-remote origin trunk | head -1`
- Uncommitted changes: !`git status --porcelain`

## Process

1. **Save Current Work** (if needed):
   ```bash
   # If you have uncommitted changes
   git stash push -m "WIP: saving work before trunk sync"
   ```

2. **Switch to Trunk**:
   ```bash
   git checkout trunk
   ```

3. **Fetch Latest**:
   ```bash
   # Fetch all updates from origin
   git fetch origin
   
   # Check what's new
   git log trunk..origin/trunk --oneline
   ```

4. **Update Trunk**:
   ```bash
   # Fast-forward merge (should always work for trunk)
   git merge --ff-only origin/trunk
   
   # If fast-forward fails, something is wrong
   # DO NOT force push to trunk!
   ```

5. **Update Gitea**:
   ```bash
   # Push updated trunk to your local Gitea
   git push local trunk
   ```

6. **Return to Work**:
   ```bash
   # Go back to your feature branch
   git checkout -
   
   # Restore stashed work if any
   git stash pop
   ```

## Optional: Rebase Feature Branch

After syncing trunk, you may want to rebase your feature branch:

```bash
git checkout <feature-branch>
git rebase trunk
git push local <feature-branch> --force-with-lease
```

## Schedule

Consider running this:
- Before starting new features
- After PRs are merged upstream
- Weekly for active projects

## Additional User Context

$ARGUMENTS