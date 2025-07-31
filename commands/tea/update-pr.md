---
description: Update a PR on Gitea using tea CLI
allowed-tools: Bash(tea pr view:*), Bash(tea pr list:*), Bash(tea pr edit:*), Bash(git log:*), Bash(git diff:*), Bash(git push:*), Read, Write, Edit
---

# Update PR (Gitea/tea)

Update an existing Pull Request on your local Gitea instance.

## Current PRs

- Your open PRs: !`tea pr list --state open --author "@me" --limit 10 2>/dev/null || echo "No tea login detected"`

## Update Process

1. **Select PR**:
   - If PR number not provided, list your open PRs and ask which to update
   - View current PR: `tea pr view <pr-number>`

2. **Update Options**:
   - **Title**: Update the PR title
   - **Description**: Update the PR description
   - **Add commits**: Push new commits to the PR branch
   - **Labels**: Add or remove labels (if available)

3. **Update Command**:
   ```bash
   # Update title and/or description
   tea pr edit <pr-number> --title "New Title" --description "New Description"
   
   # To add new commits:
   # 1. Check out the PR branch
   # 2. Make changes and commit
   # 3. Push to update the PR
   ```

## Common Updates

- Adding testing instructions
- Clarifying implementation details
- Addressing review feedback
- Updating after rebasing
- Adding related issue links

## Additional User Context

$ARGUMENTS