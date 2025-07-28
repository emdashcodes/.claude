---
description: Spec: Generate Implementation Tasks
allowed-tools: Read, Write, Edit, MultiEdit, Glob, Grep, LS, Task
---

# Spec: Implementation Tasks Generation

Generate a detailed task list for implementing the approved requirements. This replaces the design phase with actionable implementation tasks.

## Prerequisites

- Approved plan.md must exist
- Approved requirements.md must exist
- User has explicitly asked to proceed to task generation

## Process

### 1. Read Context

**Read spec files**:
- `.claude/specs/{feature_name}/plan.md` - Overall vision
- `.claude/specs/{feature_name}/requirements.md` - What to implement

**Analyze requirements** to determine:
- Technical components needed
- Implementation order and dependencies
- Integration points with existing code

### 2. Generate Tasks Document

Create `tasks.md` with the following structure:

```markdown
# Implementation Tasks: [Feature Name]

## Overview
[Brief summary of what will be built]

## Task List

- [ ] **Task 1: [High-level task name]**
  - Description: [What this task accomplishes]
  - Acceptance Criteria:
    - [ ] [Specific deliverable 1]
    - [ ] [Specific deliverable 2]
  - Implementation Notes:
    - [Technical approach]
    - [Files to create/modify]
    - [Integration points]

- [ ] **Task 2: [Next task]**
  - Description: [Purpose]
  - Dependencies: Task 1
  - Acceptance Criteria:
    - [ ] [Deliverable]
  - Implementation Notes:
    - [Approach]
```

### 3. Task Guidelines

**Good Tasks**:
- Atomic and independently completable
- Clear acceptance criteria
- Implementable by a coding agent
- Build incrementally on previous tasks
- Include file paths and component names

**Avoid**:
- Vague descriptions like "implement feature"
- Tasks that are too large (break them down)
- Non-coding tasks (unless essential)
- Time estimates

### 4. Automatic Quality Review

After generating initial tasks:

```python
Task(
    description="Review implementation tasks",
    prompt=f"Review the tasks.md at {spec_path}. Ensure all requirements have tasks, tasks are properly sized, and dependencies are logical.",
    subagent_type="spec-reviewer"
)
```

### 5. User Approval

- Present the reviewed tasks to the user
- Ask: "Do these implementation tasks look good? We can adjust them if needed."
- Iterate based on feedback
- Get explicit approval before proceeding

### 6. Common Task Categories

**Setup Tasks**:
- Create folder structure
- Set up configuration
- Initialize components

**Core Implementation**:
- Build main features
- Implement business logic
- Create data models

**Integration Tasks**:
- Connect to existing systems
- Update interfaces
- Modify shared components

**Testing Tasks** (if specified in requirements):
- Unit tests
- Integration tests
- End-to-end tests

**Documentation Tasks** (if required):
- API documentation
- User guides
- Code comments

## Important Notes

- Tasks should map directly to requirements
- Each requirement should have at least one task
- Tasks should be executable by the coder agent
- Keep tasks focused and achievable
- Order tasks to minimize blockers