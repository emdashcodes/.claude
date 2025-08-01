---
description: Create a new Gitea-only repository
allowed-tools: Bash(git init:*), Bash(git remote:*), Bash(tea repo create:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Write, Bash
---

# Create New Gitea Repository

Initialize a new repository that exists only on Gitea (no GitHub remote).

## Context

- Current directory: !`pwd`
- Directory name: !`basename $(pwd)`
- Existing git repo?: !`git rev-parse --is-inside-work-tree 2>/dev/null || echo "Not a git repository"`

## Process

1. **Repository initialization**:
   - If not already a git repo, run `git init`
   - Create initial `.gitignore` if needed
   - Add README.md with project description (optional)

2. **Create on Gitea**:
   - Use `tea repo create --name <repo-name> --private`
   - Default to private unless specified otherwise
   - Add description if provided

3. **Set up remote**:
   - Add single remote named "origin" (not "local" since there's no GitHub)
   - Format: `git@git.hollow.dev:emdash/<repo-name>.git`

4. **Initial commit and push**:
   - Create initial commit with basic files
   - Push to trunk branch: `git push -u origin trunk`
   - Set trunk as default branch

5. **Configure repository**:
   - Set default branch to trunk
   - Configure any additional settings

## Notes

- For Gitea-only repos, we use "origin" as the remote name (not "local")
- Default branch is "trunk" to match our conventions
- Repository is private by default for local development

## Additional User Context

$ARGUMENTS