---
description: Orchestrates multiple specialized PR review agents for comprehensive code review
allowed-tools: Task, Bash, Read, Write
---

# PR Review

Spawns multiple specialized PR review agents to provide comprehensive, multi-perspective code review.

## Overview

Your task is to:

1. Gather PR context (changes, description, affected files)
2. Understand codebase structure and conventions
3. **Spawn multiple review agents concurrently** for different aspects, making sure they each have the above context
4. Consolidate all reviews into a single comprehensive file at `.claude/reviews/{repo}-{number}-{slug}.md`

**IMPORTANT**: Maintain a pragmatic, balanced approach. Consider real-world constraints like time, resources, and business priorities. Focus on what truly matters rather than perfectionism.

## File Naming Convention

Reviews are saved as: `{repo}-{number}-{slug}.md`

- `{repo}`: Repository name (e.g., "wordpress", "gutenberg")
- `{number}`: PR number (e.g., "123", "4567")
- `{slug}`: Brief description slug (e.g., "update-user-auth", "fix-message-rendering")

Examples:

- `wordpress-123-fix-user-dashboard.md`
- `gutenberg-4567-add-ability-api.md`
- `woocommerce-890-update-payment-gateway.md`

## Instructions

### 1. Gather PR Context

First, collect essential PR information:

- PR description and objectives
- Changed files list
- Diff of changes
- **Existing reviews and their feedback**
- **Comment threads and discussions**
- **Review status (approved, changes requested, etc.)**
- Codebase architecture overview

Parse the PR details:

- If URL provided (e.g., `https://github.com/org/repo/pull/12345` or GitHub Enterprise):
  - Extract full repo URL: "<https://github.com/org/repo>"
  - Extract repo name: "repo"
  - Extract number: "12345"
  - Generate slug from PR title
- If no URL, use current repo URL from git remote

First, get the PR title to generate the correct directory name:

**PR Title**: !`gh pr view {pr-number} --repo {repo-url} --json title | jq -r '.title' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g' | cut -c1-50`

Use these commands to gather context and write files:

```bash
# Set up directories and variables using the actual PR title slug
WORKING_DIR=$(pwd)
PR_SLUG="!`gh pr view {pr-number} --repo {repo-url} --json title | jq -r '.title' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g' | cut -c1-50`"
mkdir -p "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG"

# Fetch all PR context using individual gh commands (these work reliably)
gh pr view {pr-number} --repo {repo-url} --json title,body,files,number,additions,deletions,changedFiles,reviews,comments,author,headRefName,baseRefName | jq '.' > "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr-info.json"

gh pr diff {pr-number} --repo {repo-url} > "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr.diff"

gh pr view {pr-number} --repo {repo-url} --comments > "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/comments.txt" || echo "No comments yet" > "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/comments.txt"

gh pr view {pr-number} --repo {repo-url} --json commits | jq -r '.commits[] | "\(.oid) \(.messageHeadline)"' > "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/commits.txt"

# Extract branch info and head commit
BASE_BRANCH=$(jq -r '.baseRefName' "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr-info.json")
HEAD_BRANCH=$(jq -r '.headRefName' "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr-info.json")
echo "Base: $BASE_BRANCH" > "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/branches.txt"
echo "Head: $HEAD_BRANCH" >> "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/branches.txt"

HEAD_COMMIT=$(gh pr view {pr-number} --repo {repo-url} --json commits | jq -r '.commits[-1].oid')
echo "$HEAD_COMMIT" > "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/head-commit.txt"
```

**For current branch PR (if no URL provided):**
```bash
# Get current repo URL and use it
REPO_URL=$(git config --get remote.origin.url)
PR_NUMBER=$(gh pr view --json number | jq -r '.number')
# Then substitute into the commands above
```

### 2. Mandatory PR Branch Checkout and Codebase Analysis

**CRITICAL**: ALWAYS checkout the PR branch in a temporary location to ensure accurate codebase analysis. This prevents review errors caused by analyzing the wrong code state.

```bash
# ALWAYS create a temporary checkout for PR analysis
TEMP_CHECKOUT_DIR="$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout"
mkdir -p "$(dirname "$TEMP_CHECKOUT_DIR")"

# Convert HTTPS URL to SSH for reliable cloning (works with any GitHub instance)
SSH_URL=$(echo "{repo-url}" | sed -E 's|https://([^/]+)/(.+)\.git$|git@\1:\2.git|' | sed -E 's|https://([^/]+)/(.+)$|git@\1:\2.git|')

# Clone and checkout the exact PR state (shallow for efficiency)
echo "Cloning repository via SSH (this may take a moment for large repos)..."
timeout 300 git clone --depth=50 "$SSH_URL" "$TEMP_CHECKOUT_DIR" || {
    echo "Clone timed out or failed. Trying with smaller depth..."
    timeout 180 git clone --depth=10 "$SSH_URL" "$TEMP_CHECKOUT_DIR" || {
        echo "ERROR: Unable to clone repository. Skipping codebase checkout."
        echo "Review will proceed with PR diff analysis only."
        TEMP_CHECKOUT_DIR=""
        cd "$WORKING_DIR"
        exit 0
    }
}

if [ -n "$TEMP_CHECKOUT_DIR" ]; then
    cd "$TEMP_CHECKOUT_DIR"
    
    # Fetch the PR branch with timeout protection
    echo "Fetching PR branch: $HEAD_BRANCH"
    timeout 120 git fetch --depth=50 origin "$HEAD_BRANCH" || {
        echo "Fetch timed out, trying with smaller depth..."
        timeout 60 git fetch --depth=10 origin "$HEAD_BRANCH" || {
            echo "WARNING: Could not fetch PR branch. Using default branch for analysis."
        }
    }
    
    # Checkout the exact commit if possible
    if git checkout --detach "$HEAD_COMMIT" 2>/dev/null; then
        echo "✓ Checked out exact commit: $(git rev-parse HEAD)"
    else
        echo "WARNING: Could not checkout exact commit. Using branch HEAD."
        git checkout --detach "origin/$HEAD_BRANCH" 2>/dev/null || {
            echo "WARNING: Using default branch for analysis."
        }
    fi
    
    cd "$WORKING_DIR"
fi

# Return to working directory
cd "$WORKING_DIR"
```

**MANDATORY**: Use codebase-researcher agents to analyze usage patterns and architecture before spawning review agents:

```python
# Spawn codebase research agents FIRST to understand context
Task("Codebase architecture analysis", "Analyze the overall architecture of the codebase at {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout. Identify: project type (React/Node/Python/etc), package structure (monorepo/single), key conventions (TypeScript/ESLint), testing approach, and architecture patterns. Look for demo/ example/ directories that show intended usage patterns. Save findings to {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/architecture-analysis.md", "codebase-researcher")

Task("Usage pattern research", "Research how the changed functions/components in the PR are actually used across the codebase at {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout. Find call sites, check demo implementations, and understand usage lifecycle (startup vs runtime vs event-driven). Focus on patterns that might affect performance analysis (e.g., functions called once vs repeatedly). Save findings to {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/usage-patterns.md", "codebase-researcher")

Task("Testing strategy analysis", "Analyze the testing patterns and current coverage in the codebase at {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout. Identify: testing frameworks used, test file naming conventions, mock patterns, coverage expectations, and how similar components are tested. Check existing test coverage for the changed files and look for recent commits that might indicate ongoing testing work or refactoring. Examine if this PR is part of a larger feature branch or ongoing work that might have tests coming in subsequent PRs. Save findings to {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/testing-strategy.md", "codebase-researcher")
```

**Why This Matters:**
- Ensures reviewers analyze the actual PR code, not trunk/main
- Prevents performance analysis errors by understanding real usage patterns  
- Provides proper context for architectural decisions
- Enables detection of patterns like "registered once at startup" vs "called repeatedly"

**Important**: All subsequent review agents will use `{absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout` as the codebase path.

### 3. Spawn Reviewers with Complete Context

The context files and codebase research have been completed in steps 1-2. Now spawn ALL reviewers in ONE message, providing them with all context files including the codebase research:

```python
# ALL IN ONE MESSAGE for concurrent execution:
# {absolute_path} = The absolute path to the working directory (from pwd command above)  
# Checkout is at {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout
Task("Code quality review", "Review the PR focusing on code quality. Read context from: {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr-info.json for PR details, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr.diff for the code changes, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/comments.txt for existing comments, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/branches.txt for branch information, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/architecture-analysis.md for codebase architecture, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/usage-patterns.md for usage pattern analysis, and {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/testing-strategy.md for testing context. The PR codebase is located at {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout. Save your review to {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/reviews/code-quality.md", "pr-reviewer")

Task("Security review", "Review the PR focusing on security. Read context from: {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr-info.json for PR details, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr.diff for the code changes, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/comments.txt for existing comments, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/branches.txt for branch information, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/architecture-analysis.md for codebase architecture, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/usage-patterns.md for usage pattern analysis, and {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/testing-strategy.md for testing context. The PR codebase is located at {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout. Save your review to {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/reviews/security.md", "pr-reviewer")

Task("Performance review", "CRITICAL: Before flagging any performance issues, READ the research/usage-patterns.md file to understand how the code is actually used. Review the PR focusing on performance. Read context from: {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr-info.json for PR details, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr.diff for the code changes, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/comments.txt for existing comments, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/branches.txt for branch information, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/architecture-analysis.md for codebase architecture, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/usage-patterns.md for usage pattern analysis, and {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/testing-strategy.md for testing context. The PR codebase is located at {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout. Save your review to {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/reviews/performance.md", "pr-reviewer")

Task("Architecture review", "Review the PR focusing on architecture. Read context from: {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr-info.json for PR details, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr.diff for the code changes, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/comments.txt for existing comments, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/branches.txt for branch information, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/architecture-analysis.md for codebase architecture, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/usage-patterns.md for usage pattern analysis, and {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/testing-strategy.md for testing context. The PR codebase is located at {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout. Save your review to {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/reviews/architecture.md", "pr-reviewer")

Task("Testing review", "Review the PR focusing on testing. Read context from: {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr-info.json for PR details, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr.diff for the code changes, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/comments.txt for existing comments, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/branches.txt for branch information, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/architecture-analysis.md for codebase architecture, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/usage-patterns.md for usage pattern analysis, and {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/testing-strategy.md for testing context. The PR codebase is located at {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout. Save your review to {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/reviews/testing.md", "pr-reviewer")

Task("Documentation review", "Review the PR focusing on documentation. Read context from: {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr-info.json for PR details, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/pr.diff for the code changes, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/comments.txt for existing comments, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/branches.txt for branch information, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/architecture-analysis.md for codebase architecture, {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/usage-patterns.md for usage pattern analysis, and {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/research/testing-strategy.md for testing context. The PR codebase is located at {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout. Save your review to {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/reviews/documentation.md", "pr-reviewer")
```

**CRITICAL: Spawn ALL reviewers concurrently in a SINGLE MESSAGE**

### 4. Create Consolidated Review

After all reviewers complete, create a single consolidated review at `$WORKING_DIR/.claude/reviews/{repo}-{number}-{slug}.md`.

**Note**: All reviewers will provide GitHub-style references with:

- Exact file paths and line numbers
- Code snippets and diff suggestions

**REVIEW LENGTH**: Keep the consolidated review focused and concise. Aim for 300-500 lines total. Synthesize similar feedback from multiple reviewers rather than duplicating it.

```markdown
# PR Review: {PR Title}

**Date**: !`date "+%Y-%m-%d %H:%M:%S %Z"`
**PR**: #{number}
**Author**: {author}
**Base Branch**: {base_branch} ← **Head Branch**: {head_branch}
**Head Commit**: {head_commit_hash}

## PR Details

**Files Changed**: {count} files (+{additions} -{deletions})
**Reviewers**: list of specialized agents, separated by commas

### Description
{PR description from pr-info.json}

### Commits
```
{List all commits from commits.txt}
```

### Changed Files
- {list of changed files from pr-info.json}

### Existing Reviews & Comments
{If there are existing reviews or comments from comments.txt, summarize them here}
{Note any already approved reviews or requested changes}

## Executive Summary

[Overall assessment synthesizing all review perspectives]

## Consolidated Findings

### Strengths
[Positive findings across all review areas - celebrate what's done well]

### Critical Issues (Blocking)
[Only truly critical items that would cause bugs, security issues, or major problems]
[Be selective and pragmatic - respect the author's time constraints]

### Important Concerns (Non-blocking but Recommended)
[Improvements that would significantly help but aren't dealbreakers]
[Acknowledge if these require substantial effort]

### Minor Suggestions (Future Improvements)
[Nice-to-have items that could be addressed in follow-up PRs]
[Code style, minor optimizations, etc.]

## Inline Comments (GitHub-Ready)

*These comments are ready to be posted as GitHub PR review comments:*

<details>
<summary>Inline Review Comments</summary>

### `path/to/file.js:42`
**Suggestion**: [Brief actionable feedback]
```javascript
// Current code
const problematicCode = value;
```
```diff
- const problematicCode = value;
+ const improvedCode = betterValue;
```

### `path/to/file.js:58-72`
**Issue**: [Clear description of the problem]
```javascript
// Current code block that needs attention
function needsImprovement() {
  // problematic implementation
}
```
**Recommendation**: [Specific actionable suggestion]

</details>

---

## Code Quality Review

[Full content from reviews/code-quality.md]

---

## Security Review

[Full content from reviews/security.md]

---

## Performance Review

[Full content from reviews/performance.md]

---

## Architecture Review

[Full content from reviews/architecture.md]

---

## Testing Review

[Full content from reviews/testing.md]

---

## Documentation Review

[Full content from reviews/documentation.md]

---

## Action Items

### Must Fix Before Merge (If Any)
1. [Only truly blocking issues]
2. [Be very selective here]

### Recommended Improvements (Non-blocking)
1. [Suggested enhancements that would be valuable]
2. [But OK to merge without if time is a factor]

### Future Considerations
1. [Items that could be addressed in follow-up PRs]
2. [Technical debt to track but not block on]

## Final Recommendation

**Decision**: [APPROVE / APPROVE WITH SUGGESTIONS / REQUEST CHANGES / NEEDS DISCUSSION]

**Rationale**: [Clear, pragmatic explanation balancing code quality with practical constraints]

**Note**: Remember that shipping working code is often better than waiting for perfect code. Consider the project timeline, team capacity, and business needs when making recommendations.
```

After creating the consolidated review, archive the artifacts and clean up:

```bash
# Create archive of all review artifacts before cleanup
cd "$WORKING_DIR/.claude/reviews/.scratch"
ARCHIVE_NAME="{repo}-{number}-$PR_SLUG.zip"
zip -r "$WORKING_DIR/.claude/reviews/$ARCHIVE_NAME" "{repo}-{number}-$PR_SLUG/" \
  -x "{repo}-{number}-$PR_SLUG/checkout/.git/*"

echo "Review artifacts archived to: .claude/reviews/$ARCHIVE_NAME"

# Clean up the temporary scratch directory
cd "$WORKING_DIR"
rm -rf "$WORKING_DIR/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG"
```

## Review Focus Customization

Based on the PR type, you may adjust which reviewers to spawn:

- **Feature PRs**: All reviewers
- **Bug Fixes**: Focus on testing, security, code quality
- **Refactoring**: Focus on architecture, performance, testing
- **Documentation**: Focus on documentation, code quality
- **Dependencies**: Focus on security, performance

## Example Usage

```bash
# Public GitHub PR
/pr-review https://github.com/facebook/react/pull/12345

# GitHub Enterprise PR (self-hosted)
/pr-review https://github.enterprise.company.com/org/repo/pull/123

# Current branch PR (determine from git remote URL)
/pr-review
```

**Note**: ALWAYS uses `--repo` flag with `gh` to ensure compatibility with both GitHub.com and GitHub Enterprise instances.

## User Request

$ARGUMENTS
