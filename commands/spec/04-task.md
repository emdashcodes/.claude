---
description: Spec: Task Execution
allowed-tools: Read, Write, Edit, MultiEdit, Glob, Grep, LS, TodoRead, TodoWrite, Task, WebFetch, mcp__perplexity-mcp__perplexity_search_web, NotebookRead, NotebookEdit
---

# Spec: 04. Task Execution

Follow these instructions for user requests related to spec tasks. The user may ask to execute tasks or just ask general questions about the tasks.

## Executing Instructions

- Before executing any tasks, ALWAYS ensure you have read the specs from the appropriate path recently:  `.claude/specs/{feature_name}/`
- You MUST read ALL spec files (requirements.md, design.md and tasks.md) directly and NOT with a Task sub agent
- Executing tasks without reading the requirements or design will lead to inaccurate implementations
- Look at all of the task details in the task list
- If the requested task has sub-tasks, always start with the sub tasks
- Only focus on ONE task at a time. Do not implement functionality for tasks not requested by the user
- Verify your implementation against any requirements specified in the task or its details
- Once you complete the requested task, stop and let the user review. DO NOT just proceed to the next task in the list
- If the user doesn't specify which task they want to work on, look at the task list for that spec and make a recommendation on the next task to execute
- You MUST mark a task as completed in the `tasks.md` file when you have completed it (in addition to TodoWrite)

Remember, it is VERY IMPORTANT that you only execute one task at a time and work on the tasks queued for you. Don't automatically continue to the next set of tasks without the user asking you to do so.

## Task Questions

The user may ask questions about tasks without wanting to execute them. Don't always start executing tasks in cases like this.

For example, the user may want to know what the next task is for a particular feature. In this case, just provide the information and don't start any tasks.
