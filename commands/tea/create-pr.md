---
description: Create a PR on Gitea using tea CLI
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git log:*), Bash(git diff:*), Bash(git branch:*), Bash(git push:*), Bash(tea pr list:*), Bash(tea pr create:*), Bash(tea pr view:*), Bash(tea repos:*), Bash(git status), Bash(git diff), Bash(git branch), Bash(git log), Bash(git remote -v)
---

# PR Request (Gitea/tea)

Create a comprehensive Pull Request on your local Gitea instance using tea CLI.

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`
- Gitea remotes: !`git remote -v | grep -E "(local|gitea|hollow)"`
- Existing PRs: !`tea pr list --limit 5 2>/dev/null || echo "No tea login detected"`

## Required Components

1. **Git Branch Name** (if still on the main branch):
   - Follow the format: `type/brief-description` (e.g., `feature/user-authentication`, `fix/login-validation`)
   - Use lowercase with hyphens
   - Keep it under 50 characters
   - If the current branch name does not seem to match the changes, ask the user for clarification

2. **Commit Message**:
   - If there are any unstaged commits, commit them: @~/.claude/commands/tea/create-commit.md

3. **Push to Gitea**:
   - Push the current branch to the 'local' remote (or whichever remote points to git.hollow.dev)
   - Use: `git push local <branch-name>`

4. **Create PR with tea**:
   - Detect the repository from remotes or ask user
   - Use: `tea pr create --repo <owner>/<repo> --title "<title>" --description "<description>" --base <base-branch> --head <feature-branch>`

5. **PR Draft Structure**:

```markdown
[Short title that summarizes the changes]

[First paragraph: Explain WHAT was changed and WHY]

[Describe HOW it was implemented (high-level technical approach)]

## Testing Instructions
- Provide step-by-step instructions that allow reviewers to verify the changes
- Each step should be actionable and specific
- Include expected outcomes
- Note any prerequisites or setup required

## Related Issues
- Link any related Gitea issues if applicable
```

## Additional Guidelines

- Do not include every single line or file changed, the Gitea PR view shows these
- Use clear, professional language
- Assume the reviewer has context about the project but not about your specific changes
- After creating, provide the PR URL from git.hollow.dev

## Additional User Context

$ARGUMENTS