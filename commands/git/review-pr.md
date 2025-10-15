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
4. Consolidate all reviews into a single comprehensive review

**IMPORTANT**: Maintain a pragmatic, balanced approach. Consider real-world constraints like time, resources, and business priorities. Focus on what truly matters rather than perfectionism.

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

**MANDATORY**: Use codebase-researcher agents to analyze usage patterns and architecture before spawning review agents to gather additional context and pass that context to the PR review agents.

### 2. Spawn Reviewers with Complete Context

Spawn ALL reviewers in ONE message, providing them with all context files including the codebase research:

```python
# ALL IN ONE MESSAGE for concurrent execution:
# {absolute_path} = The absolute path to the working directory (from pwd command above)  
# Checkout is at {absolute_path}/.claude/reviews/.scratch/{repo}-{number}-$PR_SLUG/checkout
Task("Code quality review", "Review the PR focusing on code quality. {codebase_context} {pr_context}", "pr-reviewer")

Task("Security review", "Review the PR focusing on code security. {codebase_context} {pr_context}", "pr-reviewer")

# Other focus areas...
```

**CRITICAL: Spawn ALL reviewers concurrently in a SINGLE MESSAGE**

### 4. Create Consolidated Review

After all reviewers complete, create a single consolidated review.

**Note**: All reviewers will provide GitHub-style references with:

- Exact file paths and line numbers
- Code snippets and diff suggestions

**REVIEW LENGTH**: Keep the consolidated review focused and concise. Aim for 300-500 lines total. Synthesize similar feedback from multiple reviewers rather than duplicating it.

Template:

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

[Review summary from sub agent]

---

## Security Review

[Review summary from sub agent]

---

## Architecture Review

[Review summary from sub agent]

etc..

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

After creating the consolidated review, clean up any artifacts.

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

## Potential Focus Areas

Assign subagents an  **assigned focus area only**, analyze.

Potential focus areas:

**Code Quality Focus**:

- Code readability and maintainability
- Adherence to project conventions
- DRY principles and code reuse
- Function/class design and responsibility
- Clean API design

**Security Focus**:

- Input validation and sanitization
- Authentication/authorization checks
- Potential vulnerabilities (XSS, injection, etc.)
- Sensitive data handling
- Dependency security concerns

**Performance Focus**:

- **CRITICAL**: Always research actual usage patterns before flagging algorithmic complexity issues
- Algorithm efficiency (but verify if it matters in practice)
- Database query optimization
- Caching opportunities
- Bundle size impact
- Memory management
- Rendering optimization

**Architecture Focus**:

- Design pattern adherence
- Module boundaries and dependencies
- API design
- API contract changes
- Backward compatibility
- Scalability considerations

**Testing Focus**:

- Usefulness of provided testing steps
- Test coverage adequacy
- Test quality and assertions
- Edge case handling
- Mock/stub appropriateness

**Documentation Focus**:

- Code comments and clarity
- API documentation updates
- README updates needed
- Type definitions/interfaces
- Example usage

## User Request

$ARGUMENTS
