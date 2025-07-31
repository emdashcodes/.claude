# Tea/GitHub Development Workflow

This document describes the private-to-public development workflow using Gitea (Tea) for local collaboration and GitHub for public releases.

## Overview

The workflow enables:

- Private development and iteration on local Gitea instance (git.hollow.dev)
- Collaboration between Em and Ada without exposing WIP to public
- Clean, professional git history on public GitHub repositories
- Seamless synchronization between local and public development

## Architecture

```
┌─────────────────┐         ┌──────────────────┐
│  Local Gitea    │         │     GitHub       │
│ (git.hollow.dev)│         │    (Public)      │
├─────────────────┤         ├──────────────────┤
│                 │         │                  │
│  Development    │   →→→   │  Production      │
│  Branches       │ publish │  Branches        │
│                 │         │                  │
│  trunk (sync) ←←←←←←←←←←← │  main/trunk      │
│                 │  pull   │                  │
└─────────────────┘         └──────────────────┘
```

## Key Principles

1. **Local trunk mirrors upstream**: The `trunk` branch on Gitea should always be a clean mirror of GitHub's main branch
2. **All development starts local**: Features are developed on Gitea with full freedom to experiment
3. **Clean history for public**: Before publishing, commits are cleaned and organized
4. **Two-way sync during reviews**: Changes flow both ways during the review process
5. **Cleanup after merge**: Both PRs are closed and branches cleaned up after merge

## Commands Reference

### Maintenance Commands

#### `/tea/sync-trunk`

Synchronize local trunk with upstream GitHub repository.

**When to use:**

- Before starting new features
- After PRs are merged upstream
- Daily/weekly for active projects

**What it does:**

1. Fetches latest from GitHub
2. Updates local trunk
3. Pushes to Gitea trunk
4. Optionally rebases feature branches

### Development Commands

#### `/tea/create-commit`

Create clean commits on your local Gitea branch.

**When to use:**

- Making commits during local development
- Before creating a PR

**What it does:**

1. Stages and commits changes
2. Uses conventional commit format
3. Pushes to Gitea remote

#### `/tea/create-pr`

Create a pull request on your local Gitea instance.

**When to use:**

- Ready for Em & Ada to review locally
- Want to track development progress

**What it does:**

1. Creates PR on Gitea
2. Sets up for collaboration
3. Enables local review cycle

#### `/tea/update-pr`

Update an existing PR on Gitea.

**When to use:**

- Need to change PR title/description
- Adding more context for review

### Publishing Commands

#### `/tea/publish-pr`

Clean up a Tea PR and publish it to GitHub with production-ready history.

**When to use:**

- Local development is complete and approved
- Ready to share with public/team

**What it does:**

1. Checks out Tea PR
2. Reorganizes commits into clean, atomic units
3. Creates production branch with semantic naming
4. Pushes to GitHub and creates PR
5. Links Tea and GitHub PRs

#### `/tea/update-published`

Push local updates to an existing GitHub PR.

**When to use:**

- After making changes based on GitHub reviews
- Need to update the public PR

**What it does:**

1. Cleans up any new commits
2. Force pushes to GitHub (safely)
3. Updates PR if needed

#### `/tea/sync-upstream`

Pull GitHub PR review changes back to local Gitea branch.

**When to use:**

- Others pushed changes to GitHub PR
- CI made automatic fixes
- Need to sync review changes locally

**What it does:**

1. Fetches changes from GitHub PR
2. Merges or rebases locally
3. Pushes to Gitea

## Complete Workflow Example

### 1. Start New Feature

```bash
# Sync trunk first
/tea/sync-trunk

# Create feature branch
git checkout -b feat/awesome-feature

# Develop and commit
/tea/create-commit
```

### 2. Local Review Cycle

```bash
# Create PR on Gitea
/tea/create-pr

# Ada reviews, requests changes
# Make updates and push
/tea/create-commit

# Update PR description if needed
/tea/update-pr
```

### 3. Publish to GitHub

```bash
# Clean up and publish
/tea/publish-pr PR_NUMBER=1

# Creates GitHub PR with clean history
```

### 4. GitHub Review Cycle

```bash
# If GitHub reviewers request changes:
# Make changes locally and sync
/tea/update-published

# If others push to GitHub PR:
/tea/sync-upstream
```

### 5. After Merge

```bash
# GitHub PR is merged
# Sync local trunk
/tea/sync-trunk

# Close Tea PR
tea pr close 1

# Clean up branches
git branch -d feat/awesome-feature
git push local --delete feat/awesome-feature
```

## Branch Naming Conventions

- `fix/` - Bug fixes (e.g., fix/login-validation)
- `feat/` - New features (e.g., feat/user-auth)
- `add/` - Adding components (e.g., add/config-parser)
- `update/` - Updates to existing features
- `docs/` - Documentation changes
- `refactor/` - Code improvements
- `try/` - Experimental changes

---

Last updated: 2025-07-30
Author: Em & Ada
