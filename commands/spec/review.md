---
description: Review spec documents for completeness, consistency, and quality
allowed-tools: Task
---

# Spec Review

Invoke the spec-reviewer agent to thoroughly review spec documents at any phase of the specification process.

The spec review will:

1. Validate spec structure and EARS compliance
2. Check requirements completeness and clarity
3. Review design feasibility and coverage
4. Assess implementation plan practicality
5. Verify cross-document consistency
6. Provide actionable feedback and recommendations

## Instructions

Parse the user input to determine:

- Feature name (to locate `.claude/specs/{feature-name}/`)
- Review scope (requirements, design, complete, or consistency)

Based on the scope, invoke the spec-reviewer with appropriate focus:

**IMPORTANT**: Gather full context before invoking the reviewer:

- Read relevant spec documents
- Understand the feature's purpose and scope
- Get codebase context (README, AI files, conventions, architecture)
- Include any user-provided context or constraints

### Requirements Review Only

```python
# {full_context} includes: feature description, codebase info, requirements document, user constraints
Task(
    description="Review requirements spec",
    prompt="Review the requirements.md for {feature-name}. {full_context}. Focus on EARS compliance, completeness, clarity, and edge case coverage. Save review to .claude/specs/{feature-name}/reviews/requirements-review.md (overwrite if exists)",
    subagent_type="spec-reviewer"
)
```

### Design Review Only

```python
# {full_context} includes: requirements, design document, codebase patterns, architecture info, user constraints
Task(
    description="Review design spec",
    prompt="Review the design.md for {feature-name}. {full_context}. Focus on technical feasibility, completeness, architecture alignment, and requirement coverage. Save review to .claude/specs/{feature-name}/reviews/design-review.md (overwrite if exists)",
    subagent_type="spec-reviewer"
)
```

### Complete Review

```python
# {full_context} includes: ALL spec documents, codebase context, feature history, user requirements
Task(
    description="Review complete spec",
    prompt="Review all spec documents for {feature-name} (requirements.md, design.md, tasks.md). {full_context}. Provide comprehensive feedback on quality, completeness, and consistency. Save review to .claude/specs/{feature-name}/reviews/complete-review.md (overwrite if exists)",
    subagent_type="spec-reviewer"
)
```

### Consistency Check

```python
# {full_context} includes: ALL spec documents, cross-references, dependencies, traceability matrix
Task(
    description="Check spec consistency",
    prompt="Review all spec documents for {feature-name} focusing on cross-document consistency, traceability, and alignment. {full_context}. Save review to .claude/specs/{feature-name}/reviews/consistency-review.md (overwrite if exists)",
    subagent_type="spec-reviewer"
)
```

## Review Outcomes

The reviewer will produce one of three statuses:

- **APPROVED**: Spec is ready for next phase/implementation
- **NEEDS REVISION**: Specific issues must be addressed
- **REJECTED**: Major rework required

## User Input

$ARGUMENTS
