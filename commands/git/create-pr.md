---
description: Create a PR
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git log:*), Bash(git diff:*), Bash(git branch:*), Bash(gh pr list:*), Bash(gh pr create:*), Bash(gh pr status:*), Bash(git status), Bash(git diff), Bash(git branch), Bash(git log)
---

# PR Request

Create a comprehensive Pull Request based on the changes we made this session as well as the current Git state.

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Required Components

1. **Git Branch Name** (if still on the main branch):
   - Follow the format: `type/brief-description` (e.g., `feature/user-authentication`, `fix/login-validation`)
   - Use lowercase with hyphens
   - Keep it under 50 characters
   - If the current branch name does not seem to match the changes, ask the user for clarification

2. **Commit Message**:
   - If there are any unstaged commits, commit them: @~/.claude/commands/create-commit.md

3. **PR Draft Structure**:

```markdown
[Short title that summarizes the changes]

[First paragraph: Explain WHAT was changed and WHY]

[Describe HOW it was implemented (high-level technical approach)]

## Testing Instructions
- Provide step-by-step instructions that allow reviewers to verify the changes
- Each step should be actionable and specific
- Include expected outcomes
- Note any prerequisites or setup required
```

## Additional Guidelines

- Do not include every single line or file changed, the GitHub PR view shows these
- Use clear, professional language
- Assume the reviewer has context about the project but not about your specific changes

## Additional User Context

$ARGUMENTS
