---
description: Sync changes from GitHub PR reviews back to local Gitea branch
allowed-tools: Bash(git:*), Bash(gh pr:*), Bash(tea pr:*), Read, Write, Edit
---

# Sync Upstream Changes (GitHub → Gitea)

Pull changes from GitHub PR reviews back to your local Gitea branch to keep them in sync.

## Context

- GitHub PR: !`gh pr status --json number,headRefName,title | jq -r '.currentBranch // empty' 2>/dev/null || echo "No current PR"`
- Local branch: !`git branch --show-current`
- Tea PR: !`tea pr list --fields index,title,head --limit 5 2>/dev/null | grep -E "$(git branch --show-current)" || echo "No matching Tea PR"`

## Process

1. **Identify PRs**:
   - Find the GitHub PR number
   - Find the corresponding Tea PR
   - Verify they're tracking the same branch

2. **Fetch GitHub Changes**:
   ```bash
   # Fetch latest from GitHub
   git fetch origin <branch-name>
   
   # Check if there are any changes
   git log HEAD..origin/<branch-name> --oneline
   ```

3. **Merge or Rebase**:
   ```bash
   # Option 1: Merge (preserves review history)
   git merge origin/<branch-name>
   
   # Option 2: Rebase (cleaner history)
   git rebase origin/<branch-name>
   ```

4. **Push to Gitea**:
   ```bash
   git push local <branch-name> --force-with-lease
   ```

5. **Update Tea PR**:
   - Add comment noting sync from GitHub
   - Update PR description if needed

## Common Scenarios

- **Review fixes**: Merge to preserve review history
- **Conflict resolution**: May need interactive rebase
- **CI fixes**: Usually merge is fine

## Additional User Context

$ARGUMENTS