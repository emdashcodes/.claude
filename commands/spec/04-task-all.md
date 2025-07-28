---
description: Spec: Task Execution
allowed-tools: Read, Write, Edit, MultiEdit, Glob, Grep, LS, TodoRead, TodoWrite, Task, WebFetch, mcp__perplexity-mcp__perplexity_search_web, NotebookRead, NotebookEdit
---

# Spec: 04. Task Execution - All Tasks

Follow these instructions for executing all tasks in a spec. This command orchestrates multiple coder agents in sequence.

## Executing Instructions

### 1. Initial Setup

**Read ALL spec files directly**:
- `.claude/specs/{feature_name}/plan.md`
- `.claude/specs/{feature_name}/requirements.md`
- `.claude/specs/{feature_name}/tasks.md`

**Create scratch folder**:
```bash
mkdir -p .claude/specs/{feature_name}/scratch
echo "# Implementation Notes\n\nShared workspace for implementation agents.\n" > .claude/specs/{feature_name}/scratch/README.md
```

### 2. Task Execution Loop

For each uncompleted task in tasks.md:

**A. Spawn Coder Agent**:
```python
Task(
    description=f"Implement task {task_number}",
    prompt=f"Implement task {task_number} from {spec_path}. Previous agents have left notes in scratch/README.md. Add your own notes for the next agent.",
    subagent_type="coder"
)
```

**B. Spawn Reviewer Agent**:
```python
Task(
    description=f"Review task {task_number}",
    prompt=f"Review implementation of task {task_number} at {spec_path}. Check spec compliance only.",
    subagent_type="implementation-reviewer"
)
```

**C. Handle Review**:
- If APPROVED: 
  - Mark task complete in tasks.md
  - Continue to next task
- If NEEDS REVISION:
  - One automatic retry with coder
  - If still fails, ask user for guidance

**D. Update Progress**:
- Update tasks.md after each task
- Show user progress summary

### 3. Identify Safe Concurrent Tasks

Some tasks CAN be run concurrently if they:
- Work on completely different files
- Have no dependencies on each other
- Are explicitly marked as independent

When safe, spawn multiple coders:
```python
# Concurrent execution example
Task(description="Task 1", prompt="...", subagent_type="coder")
Task(description="Task 3", prompt="...", subagent_type="coder") 
Task(description="Task 5", prompt="...", subagent_type="coder")
```

### 4. Final Documentation

After all tasks complete:
```python
Task(
    description="Finalize documentation",
    prompt=f"Finalize the implementation at {spec_path}. Update project docs, reset tasks.md, clean scratch folder, and provide final report.",
    subagent_type="documentor"
)
```

### 5. Completion

- Show final report to user
- Confirm all tasks marked complete
- Spec ready for future reference

## Important Notes

- Each coder works independently but can read previous notes
- Review happens after each task to ensure quality
- User can interrupt the sequence at any time
- Progress is saved after each task

