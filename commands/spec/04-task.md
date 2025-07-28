---
description: Spec: Task Execution - Single Task
allowed-tools: Read, Write, Edit, MultiEdit, Glob, Grep, LS, TodoRead, TodoWrite, Task, WebFetch, mcp__perplexity-mcp__perplexity_search_web, NotebookRead, NotebookEdit
---

# Spec: 04. Task Execution - Single Task

Follow these instructions for executing a single spec task. This command uses the new coder agent for implementation.

## Executing Instructions

### 1. Read Spec Files

Before executing any tasks, ALWAYS read ALL spec files directly:
- `.claude/specs/{feature_name}/plan.md` - Understand the overall goal
- `.claude/specs/{feature_name}/requirements.md` - Know what to build  
- `.claude/specs/{feature_name}/tasks.md` - See task details

Note: Read these yourself, not through a Task agent.

### 2. Create Scratch Folder

Create the scratch folder for agent communication:
```bash
mkdir -p .claude/specs/{feature_name}/scratch
```

### 3. Spawn Coder Agent

Launch the coder agent for the specified task:
```python
Task(
    description=f"Implement task {task_number}",
    prompt=f"You are implementing task {task_number} from the spec at {spec_path}. Focus ONLY on this task and its subtasks. Complete everything before stopping. Use scratch/README.md for notes.",
    subagent_type="coder"
)
```

### 4. Review Implementation

After coder completes:
```python
Task(
    description="Review implementation",
    prompt=f"Review the implementation of task {task_number} at {spec_path}. Verify it matches the spec requirements exactly. Write review to scratch/REVIEW.md.",
    subagent_type="implementation-reviewer"
)
```

### 5. Handle Review Outcome

- If APPROVED: Mark task as complete in tasks.md
- If NEEDS REVISION: 
  - Show user the review
  - Ask if they want automatic fixes
  - If yes, spawn coder again with review feedback
  - Repeat review cycle

### 6. Clean Up (Optional)

If this is a standalone task (not part of a sequence):
- Remove scratch folder
- Inform user task is complete

Remember: Only execute ONE task at a time. Let the user review before proceeding to the next task.

## Task Questions

The user may ask questions about tasks without wanting to execute them. Don't always start executing tasks in cases like this.

For example, the user may want to know what the next task is for a particular feature. In this case, just provide the information and don't start any tasks.
