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
# Title (75 chars max, no prefix)

[One paragraph summary of what changed and why it matters]

Fixes #[issue] (if applicable)

## Why
[One paragraph explaining the motivation/problem]

## How
[One paragraph explaining the technical approach]
- Bullet points for details if needed

## Testing Steps
1. [Specific action]
2. [Expected result]
3. [How to verify]
```

## Additional Guidelines

- Do not include every single line or file changed, the GitHub PR view shows these
- Use clear, professional language
- Assume the reviewer has context about the project but not about your specific changes

## Additional User Context

$ARGUMENTS
