---
description: Clean up a Tea PR and publish it to GitHub with clean history
allowed-tools: Bash(tea pr:*), Bash(git:*), Bash(gh pr:*), Read, Write, Edit
---

# Publish PR to GitHub (Tea → GitHub)

Take a PR from your local Gitea instance, create a production-ready branch with clean atomic commits, and create a corresponding PR on GitHub.

## Context

- Tea PR to publish: !`tea pr view ${PR_NUMBER:-"<specify>"} 2>/dev/null || echo "Specify PR number"`
- Current branch: !`git branch --show-current`
- GitHub remote: !`git remote -v | grep -E "(origin|github)" | head -1`

## Process

1. **Checkout Tea PR**:

   ```bash
   tea pr checkout <pr-number>
   ```

2. **Analyze Current Commits**:
   - Review all commits in the PR
   - Identify logical groupings for atomic commits
   - Note any test commits, WIP commits, or fixes to squash

3. **Create Clean Production Branch**:

   ```bash
   # Branch name should match the change type:
   # fix/issue-name, feat/feature-name, update/component-name, 
   # add/new-thing, docs/update-docs, refactor/cleanup-x, etc.
   git checkout -b <type>/<descriptive-name>
   git reset --soft <base-branch>
   ```

4. **Create Atomic Commits**:
   - Stage and commit changes in logical groups
   - Each commit should:
     - Have a clear, descriptive message
     - Be atomic (one logical change)
     - Pass tests independently
     - Follow conventional commit format (feat:, fix:, docs:, etc.)

5. **Example Commit Structure**:

   ```bash
   # Instead of:
   # - "WIP: started feature"
   # - "fix typo"
   # - "addressing review comments"
   # - "final touches"
   
   # Create:
   git add <files-for-feature-core>
   git commit -m "feat: implement core feature functionality"
   
   git add <files-for-tests>
   git commit -m "test: add comprehensive test coverage"
   
   git add <files-for-docs>
   git commit -m "docs: update documentation and examples"
   ```

6. **Push to GitHub**:

   ```bash
   git push origin <type>/<descriptive-name>
   ```

7. **Create GitHub PR**:
   - Copy relevant information from Tea PR
   - Enhance description for public audience
   - Create PR: `gh pr create --base main --head <type>/<descriptive-name>`

8. **Link Back to Tea**:
   - Add comment on Tea PR with GitHub PR link
   - Keep both PRs open for the review cycle

## After GitHub PR is Merged

1. **Update Local Trunk**:
   ```bash
   git checkout trunk
   git pull origin trunk
   ```

2. **Close Both PRs**:
   ```bash
   # Close GitHub PR (automatic if merged via web)
   # Close Tea PR
   tea pr close <tea-pr-number>
   ```

3. **Clean Up Branches**:
   ```bash
   # Delete local branch
   git branch -d <feature-branch>
   
   # Delete remote branches
   git push origin --delete <feature-branch>
   git push local --delete <feature-branch>
   ```

## Branch Naming Convention

Choose branch names that match the type of change:

- **fix/**: Bug fixes (e.g., fix/login-validation)
- **feat/**: New features (e.g., feat/user-auth)
- **add/**: Adding new components (e.g., add/config-parser)
- **update/**: Updating existing features (e.g., update/api-response)
- **docs/**: Documentation changes (e.g., docs/api-guide)
- **refactor/**: Code improvements (e.g., refactor/database-layer)
- **try/**: Experimental changes (e.g., try/new-algorithm)
- **chore/**: Maintenance tasks (e.g., chore/update-deps)

## Clean Commit Guidelines

- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation only
- **style:** Code style (formatting, semicolons, etc)
- **refactor:** Code restructuring without behavior change
- **test:** Adding or updating tests
- **chore:** Maintenance tasks

## Output

After completion, provide:

1. GitHub PR URL
2. Summary of how commits were reorganized
3. Any notable changes made for production

## Additional User Context

$ARGUMENTS
