# GitHub PR Draft Review Workflow

## Overview

The PR Draft Review workflow ensures that all GitHub Pull Requests are reviewed and properly formatted before submission. This system intercepts `gh pr create` commands and enforces a review cycle.

## How It Works

### 1. Interception

When you run `gh pr create`, the `github-pr-draft.sh` hook intercepts the command and:
- Extracts the PR title and body from the command
- Saves the content to a draft file
- Creates a session-specific lock file with "pending" status
- Blocks the command and displays template guidelines

### 2. Review Phase

You'll see:
- The PR template guidelines showing the expected format
- Instructions to use `/pr-draft:approve` or `/pr-draft:cancel`
- The location of your saved draft

### 3. Approval

Run `/pr-draft:approve` to:
- View your saved draft content
- Update the lock status to "approved"
- Get the exact command to re-run

### 4. Submission

Re-run your original `gh pr create` command:
- The hook detects the "approved" status
- Allows the command to proceed
- Automatically cleans up draft and lock files after success

### 5. Cancellation

Run `/pr-draft:cancel` to:
- Remove the lock file
- Delete the draft
- Start fresh with a new PR

## Configuration

### Draft Directory

The draft directory is configured in `~/.claude/config/pr-draft-config.json`:

```json
{
  "draft_dir": ".claude/drafts"
}
```

This path is relative to your current working directory. Drafts are saved as:
```
.claude/drafts/pr-draft-[session-id].md
```

### PR Template

The template is located at `~/.claude/templates/pr-template.md` and provides:
- Title guidelines (75 chars max, no prefix)
- Issue reference format
- Section structure (Summary, Why, How, Testing Steps)

## Lock File Management

Lock files are stored in `.claude/state/` with the format:
```
pr-draft-[session-id].lock
```

Lock file structure:
```json
{
  "status": "pending|approved",
  "session_id": "xxx",
  "created_at": "2025-01-11T...",
  "draft_file": "path/to/draft",
  "command": "original gh pr create command"
}
```

## Commands

### `/pr-draft:approve`
- Reviews the saved draft
- Marks it as approved
- Provides the command to submit

### `/pr-draft:cancel`
- Removes lock and draft files
- Cancels the PR submission

## Troubleshooting

### No Session ID

If running outside a Claude session, the system falls back to using the process ID ($$).

### Missing Draft

If the draft file is missing but a lock exists, use `/pr-draft:cancel` to reset.

### Already Approved

If you run `/pr-draft:approve` twice, it will remind you to re-run the `gh pr create` command.

### Cleanup Issues

The hook attempts automatic cleanup after successful PR creation. If files remain:
```bash
# Manual cleanup
rm .claude/state/pr-draft-*.lock
rm .claude/drafts/pr-draft-*.md
```

## Integration with Git Workflow

This hook works alongside the git-commit hook to ensure both commits and PRs follow standards:
1. Git commits are validated for format and length
2. PRs are reviewed before submission
3. Both use session-specific tracking

## Customization

### Disable Review for Specific Session

To temporarily bypass PR review:
```bash
export CLAUDE_DISABLE_HOOKS=1
```

### Modify Template

Edit `~/.claude/templates/pr-template.md` to customize the guidelines shown during review.

### Change Draft Location

Update `~/.claude/config/pr-draft-config.json` to save drafts elsewhere:
```json
{
  "draft_dir": "/tmp/pr-drafts"
}
```

## Best Practices

1. **Review Before Approval**: Always read the draft content when approving
2. **Follow Template**: Structure PRs according to the template for consistency
3. **Clean Titles**: Keep PR titles under 75 characters without prefixes
4. **Link Issues**: Include "Fixes #123" when applicable
5. **Test Steps**: Provide clear, actionable testing instructions

## Example Workflow

```bash
# 1. Create a PR (gets blocked)
$ gh pr create --title "Add user authentication" --body "..."
# PR Draft Review Required!
# Draft saved to: .claude/drafts/pr-draft-abc123.md

# 2. Review and approve
$ /pr-draft:approve
# ✅ PR draft APPROVED

# 3. Re-run the command
$ gh pr create --title "Add user authentication" --body "..."
# PR created successfully!
# (Draft and lock automatically cleaned up)
```