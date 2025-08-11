---
description: Generate implementation tasks from approved requirements
allowed-tools: Task, TodoWrite, Read, Bash
---

# Spec Workflow: Tasks

Generate tasks.md from approved requirements

## Process

1. **Verify Prerequisites**:
   - Ensure requirements.md exists and is approved
   - Ensure design.md exists (REQUIRED)
   - Read full requirements and design documents for context
   - Understand all constraints and technical decisions

2. **Generate Tasks**:
   - Spawn spec-tasks agent with full context
   - Agent creates numbered implementation tasks
   - Tasks saved to `.claude/specs/{feature-name}/tasks.md`

3. **Review Cycle**:
   - Present tasks for human review
   - Make any requested changes
   - When approved, user can use `/spec:workflow:implement`

## Implementation

When invoked:

1. Check if requirements.md exists and status
2. Read the full requirements document
3. Check if design.md exists and read it
4. Spawn spec-tasks agent with MAXIMUM context:

```python
Task(
    description="Generate tasks for {feature-name}",
    # CRITICAL: Give MAXIMUM CONTEXT to generate accurate, implementable tasks
    prompt="""
    Feature: {feature-name}

    FULL REQUIREMENTS DOCUMENT:
    {full-requirements-content}

    FULL DESIGN DOCUMENT (REQUIRED):
    {full-design-content}

    Additional Context Provided by User:
    - Constraints: {user-constraints}
    - Technical specifications: {user-technical-details}
    - Exclusions: {user-exclusions}
    - Implementation preferences: {implementation-preferences}

    Project Context:
    - Codebase structure: {codebase-structure}
    - Technology stack: {tech-stack}
    - Testing approach: {testing-approach}
    - Code conventions: {code-conventions}
    - Existing patterns: {existing-patterns}

    IMPORTANT INSTRUCTIONS:
    1. Do a quick scan of the codebase for practical conventions:
       - Test file locations and naming patterns
       - Build/lint commands from package.json or similar
       - File organization for this type of feature
    2. Create tasks ONLY for coding activities
    3. Honor ALL user constraints and exclusions
    4. Each task must be implementable by a coding agent
    5. Reference specific requirements in each task
    6. Create tasks.md at: .claude/specs/{feature-slug}/tasks.md
    7. Ensure tasks build incrementally
    8. Group related tasks logically
    9. Include specific file paths and components

    Convert the requirements into discrete, implementable coding tasks that follow
    the codebase's practical conventions.
    """,
    subagent_type="spec-tasks"
)
```

## Example Flow

```text
User: /spec:workflow:tasks
Assistant: I'll generate implementation tasks from your approved requirements.

[Reads requirements.md to understand the feature]
[Spawns spec-tasks agent with full context]

Tasks have been generated at: .claude/specs/authentication/tasks.md

Please review the tasks. When ready to implement, use:
- `/spec:workflow:implement` to begin implementation
```

## Prerequisites

- Requirements must exist at `.claude/specs/{feature-name}/requirements.md`
- Design must exist at `.claude/specs/{feature-name}/design.md`
- Both should be in "approved" status
- User should have reviewed and approved both documents

## Error Handling

- If requirements.md is missing: Inform user to create requirements first
- If design.md is missing: Inform user to create design first using `/spec:workflow:design`
