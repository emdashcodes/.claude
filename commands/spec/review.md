---
description: Request manual spec review
allowed-tools: Read, Task, Bash
---

# Spec: Review

This command allows manual review of spec documents at any stage of the spec workflow.

## Usage

When the user requests a spec review, determine the last spec step completed OR which spec documents exist, then spawn the appropriate reviewer.

## Review Process

### 0. Find Available Specs

Check what specs are available to review:
!`~/.claude/helpers/list-specs.sh`

### 1. Identify What to Review

Check which spec documents exist for the feature:
- `.claude/specs/{feature_name}/plan.md`
- `.claude/specs/{feature_name}/requirements.md`
- `.claude/specs/{feature_name}/tasks.md`

### 2. Spawn Appropriate Reviewer

Based on what exists, spawn the appropriate reviewer agent:

#### For Plan Review
```python
Task(
    description="Review plan",
    prompt="Review the plan at {plan_path}. Check for clarity, completeness, technical feasibility, and alignment with project goals. IMPORTANT CONTEXT FROM USER: {context_from_conversation}",
    subagent_type="spec-reviewer"
)
```

#### For Requirements Review
```python
Task(
    description="Review requirements",
    prompt="Review the requirements at {requirements_path} against the plan at {plan_path}. Check EARS format compliance, completeness, and alignment with the plan. IMPORTANT CONTEXT FROM USER: {context_from_conversation}",
    subagent_type="spec-reviewer"
)
```

#### For Tasks Review
```python
Task(
    description="Review tasks",
    prompt="Review the tasks at {tasks_path} against requirements at {requirements_path}. Check task breakdown, incremental approach, and coverage of all requirements. IMPORTANT CONTEXT FROM USER: {context_from_conversation}",
    subagent_type="spec-reviewer"
)
```

**Note**: When spawning reviewers, always include relevant context from the conversation such as:
- User constraints (e.g., "NO unit tests", "WordPress already configured")
- User preferences (e.g., "simple implementation", "no Jetpack")
- Existing setup (e.g., "WordPress at /Users/emdash/Studio/emdashcodes")
- Decisions made during discussion

#### For Full Spec Review
If all documents exist, spawn multiple reviewers concurrently:
```python
# Review all spec documents
Task("Review plan", "...", "spec-reviewer")
Task("Review requirements", "...", "spec-reviewer")
Task("Review tasks", "...", "spec-reviewer")
```

## Important Notes

- This command is for manual review requests only
- The spec workflow automatically includes reviews at appropriate stages
- Manual reviews don't change the workflow state
- Reviews provide feedback but don't block progress

## Example Usage

```
User: Review the authentication spec
Assistant: I'll review the authentication spec documents.

[Reads spec files to determine what exists]
Found plan.md and requirements.md. Spawning reviewers...

[Spawns appropriate review agents]
[Presents review feedback to user]
```