---
description: Spec 03: Implementation
allowed-tools: Read, Task, TodoWrite
---

# Spec: 03. Implementation

This command implements ALL tasks in a feature's tasks.md file automatically using a coder-reviewer loop.

## Implementation Process

When the user asks to implement a feature, follow these steps:

### 1. Read Feature Context

- Read `.claude/specs/{feature_name}/requirements.md` to understand the feature
- Update requirements.md frontmatter `status: implementing`
- Read `.claude/specs/{feature_name}/tasks.md` to get the implementation tasks
- Use TodoWrite to create a list of ALL tasks to implement
- ALWAYS read BOTH files directly before each task, even if you recently read them

### 2. Implement Each Task

For each task in the tasks.md file:

1. **Spawn Coder Agent**:

   ```python
   Task(
       description="Implement task X",
       prompt="Implement task X from {feature-name}. Requirements: {requirements_content}. Task details: {task_details}. Focus on this task only and complete all subtasks.",
       subagent_type="coder"
   )
   ```

2. **Spawn Code Reviewer**:

   ```python
   Task(
       description="Review task X implementation",
       prompt="Review the implementation of task X for {feature-name}. Requirements: {requirements_content}. Task: {task_details}. Check compliance with requirements and project conventions.",
       subagent_type="code-reviewer"
   )
   ```

3. **Handle Review Feedback**:
   - If reviewer returns `APPROVED`: Mark task complete and move to next task
   - If reviewer returns `NEEDS_CHANGES`:
     - Spawn coder again with the review feedback
     - Continue loop until approved
     - Maximum 5 iterations per task before escalating to user

4. **Update Progress**:
   - Use TodoWrite to mark current task as completed
   - Update the tasks.md file marking completed tasks with [x]

### 3. Complete Implementation

Once all tasks are complete:

- Update requirements.md frontmatter `status: completed`
- **Update TODO.md (if exists)**:
  - Check if `TODO.md` exists in the project root
  - If it exists, find and mark completed items with `[x]` for the implemented feature
  - Be conservative - only mark items you're confident are completed
  - Preserve existing structure and content
- Inform the user that all tasks have been implemented
- Provide a summary of what was implemented
- Mention if TODO.md was updated (if applicable)
- Suggest running tests to verify the implementation
- Suggest running the complete command to generate architecture documentation

## Important Guidelines

- Work through tasks sequentially
- Don't skip tasks or implement multiple tasks at once
- Each task must be approved before moving to the next
- If a task fails after 5 review cycles, stop and ask the user for guidance
- Keep the user informed of progress (which task is being worked on, how far along it is, what is left to do)

## Error Handling

- If requirements.md is missing: Stop and inform the user
- If tasks.md is missing: Stop and inform the user
- If a task repeatedly fails review: Escalate to user with details

## Example Flow

```text
User: Implement the authentication feature
Assistant: I'll implement all tasks for the authentication feature.

Reading requirements and tasks...
Found 5 tasks to implement.

Starting Task 1: Create user model...
[Spawns coder]
[Spawns code-reviewer]
✓ Task 1 approved and complete

Starting Task 2: Implement password hashing...
[Continues through all tasks]
```
