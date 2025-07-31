---
description: Push local updates to an existing GitHub PR
allowed-tools: Bash(git:*), Bash(gh pr:*), Bash(tea pr:*), Read, Write, Edit
---

# Update Published PR (Gitea → GitHub)

Push updates from your local Gitea development to an existing GitHub PR.

## Context

- Local branch: !`git branch --show-current`
- Local commits: !`git log --oneline -5`
- GitHub PR: !`gh pr list --head $(git branch --show-current) --json number,title,state | jq -r '.[] | "#\(.number) - \(.title) (\(.state))"' 2>/dev/null || echo "No GitHub PR found"`

## Process

1. **Verify PR State**:
   - Ensure GitHub PR exists and is open
   - Confirm you're on the correct branch
   - Check that local is ahead of GitHub

2. **Clean Up History** (if needed):
   ```bash
   # Interactive rebase to clean up new commits
   git rebase -i origin/<branch-name>
   
   # Squash fix commits, reword as needed
   ```

3. **Push Updates**:
   ```bash
   # Force push with lease for safety
   git push origin <branch-name> --force-with-lease
   ```

4. **Update PR Description** (if needed):
   ```bash
   gh pr edit <pr-number> --body-file updated-description.md
   ```

5. **Add Comment**:
   ```bash
   gh pr comment <pr-number> --body "Updated with latest changes from local development"
   ```

## Best Practices

- Always use `--force-with-lease` to avoid overwriting others' changes
- Keep commit messages clean and descriptive
- Update PR description if scope changed
- Note any new testing instructions

## Additional User Context

$ARGUMENTS