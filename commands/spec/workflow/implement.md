---
description: Spec Implementation
allowed-tools: Read, Task, TodoWrite, Bash
---

# Spec: Implementation

This command implements ALL tasks in a feature's tasks.md file automatically using a coder-reviewer loop.

## Spec Document Hierarchy

The implementation follows a strict hierarchy of specifications:

1. **requirements.md** - Defines WHAT to build (the goals)
2. **design.md** - Defines HOW to build it (the blueprint)  
3. **tasks.md** - Defines STEPS to build it (the checklist)

All implementation MUST follow this hierarchy. The design is the contract between planning and implementation.

## Implementation Process

When the user asks to implement a feature, follow these steps:

### 0. Find Available Specs

Check what specs are available:
!`~/.claude/helpers/list-specs.sh`

If the user doesn't specify which spec, list available options and ask which one to implement.

### 1. Initialize Context (CRITICAL for resumed sessions)

**Always check implementation state first:**

1. **Spawn codebase-researcher** to verify actual implementation status:
   ```python
   Task(
       description="Research current implementation status",
       # CRITICAL: Give MAXIMUM CONTEXT to accurately assess implementation state
       prompt="Research the current implementation status for {feature-name}. Check what's actually implemented vs what tasks.md says. Look for any incomplete work, TODO comments, or mismatches between documentation and code. Full requirements: {full_requirements_content}. Full design: {full_design_content}. Full tasks list: {full_tasks_content}. Verify implementation aligns with design decisions. Provide detailed findings on what's actually implemented vs documented.",
       subagent_type="codebase-researcher"
   )
   ```

2. **Compare findings with tasks.md** to identify:
   - Tasks marked complete but not actually implemented
   - Tasks partially implemented
   - Tasks implemented but not marked complete
   - Any work done outside the task list

3. **Update tasks.md** to reflect true state before proceeding

### 2. Read Feature Context and Setup Tracking

- Get spec path: `SPEC_PATH=$(spec-config)`
- Read `${SPEC_PATH}/{feature_name}/requirements.md` to understand the feature
- Read `${SPEC_PATH}/{feature_name}/design.md` to understand design decisions
- Update requirements.md frontmatter `status: implementing`
- Read `${SPEC_PATH}/{feature_name}/tasks.md` to get the implementation tasks
- **Group tasks into logical milestones** (3-7 tasks each)
- Use TodoWrite to create milestone tracking with:
  - Each milestone implementation as a todo item with status "pending"
  - Each milestone code review as a separate todo item with status "pending"
  - Brief description of what tasks are in each milestone
  - Mark as high priority for active work tracking
  - **Format**: "Milestone X: [Name] (tasks Y-Z)" and "Milestone X: Code Review"
- ALWAYS read ALL THREE spec files (requirements, design, tasks) directly before starting each milestone

### 2. Implement Tasks by Milestone

Group tasks into logical milestones and implement them in batches:

1. **Identify Milestones**:
   - Group related tasks into small, cohesive units
   - **Ideal size: 3-5 tasks per milestone** (never more than 7)
   - Each milestone should take roughly 1-2 hours to implement
   - Aim for functional units that can be reviewed together
   
   **Good milestone examples:**
   - "Basic User Model" (3 tasks): Create schema, add validations, implement CRUD
   - "Authentication Flow" (4 tasks): Login endpoint, password hashing, session handling, logout
   - "Error Handling Setup" (3 tasks): Error types, middleware, response formatting
   
   **Bad milestone examples:**
   - "Complete Authentication System" (15 tasks) - Too large, break into 3-4 milestones
   - "Database Setup" (1 task) - Too small, combine with related tasks
   - "All API Endpoints" (20 tasks) - Way too large, group by resource or feature

2. **Implement Milestone Tasks**:
   - Mark current milestone as "in_progress" using TodoWrite
   - Spawn coder agent:

   ```python
   Task(
       description="Implement milestone: {milestone_name}",
       # CRITICAL: Give MAXIMUM CONTEXT with DESIGN as primary guide
       prompt="""Implement milestone '{milestone_name}' for {feature-name}.
       
       PRIMARY GUIDE - DESIGN DOCUMENT:
       {full_design_content}
       
       REQUIREMENTS (for reference):
       {full_requirements_content}
       
       TASKS TO IMPLEMENT:
       {milestone_tasks_list_with_numbers}
       
       IMPLEMENTATION CONTEXT:
       - Previous milestones completed: {previous_milestones_summary}
       - Project conventions: {code_conventions}
       - Technology stack: {tech_stack}
       
       CRITICAL INSTRUCTIONS:
       1. Follow the DESIGN DOCUMENT as your primary guide
       2. Implement exactly as specified in the design (architecture, components, patterns)
       3. Reference design sections when implementing (e.g., "Implementing auth as per Design Section 3")
       4. Complete ALL tasks in this milestone
       5. Mark each completed task with [x] in tasks.md
       6. Ensure integration with previously completed work
       7. Your implementation MUST match the design specifications exactly
       """,
       subagent_type="coder"
   )
   ```

3. **Review Milestone Implementation**:
   - Mark the milestone code review todo as "in_progress" using TodoWrite
   - Spawn reviewer agent:

   ```python
   Task(
       description="Review milestone: {milestone_name}",
       # CRITICAL: Review against DESIGN SPECIFICATIONS
       prompt="""Review milestone '{milestone_name}' implementation for {feature-name}.
       
       REVIEW STANDARD - DESIGN DOCUMENT:
       {full_design_content}
       
       REQUIREMENTS (for completeness check):
       {full_requirements_content}
       
       COMPLETED TASKS TO VERIFY:
       {milestone_tasks_list_with_numbers}
       
       IMPLEMENTATION CHANGES:
       {git_diff_for_milestone}
       
       REVIEW CONTEXT:
       - Previous milestones: {previous_milestones_summary}
       - Project conventions: {code_conventions}
       
       REVIEW CRITERIA (based on design):
       1. Implementation matches DESIGN SPECIFICATIONS exactly
       2. Architecture follows design document (Section 3)
       3. Components match design interfaces (Section 4)
       4. Data models align with design (Section 5)
       5. Error handling follows design strategy (Section 6)
       6. Testing approach matches design (Section 7)
       7. Security measures per design (Section 8)
       8. Performance considerations implemented (Section 9)
       9. All milestone tasks completed
       10. Integration with previous milestones works
       
       Return APPROVED only if implementation matches design exactly.
       Return NEEDS_CHANGES with specific references to design sections if not.
       """,
       subagent_type="code-reviewer"
   )
   ```

4. **Handle Milestone Review Feedback**:
   - If reviewer returns `APPROVED`: 
     - Mark milestone implementation todo as "completed" using TodoWrite
     - Mark milestone code review todo as "completed" using TodoWrite
     - Move to next milestone
   - If reviewer returns `NEEDS_CHANGES`:
     - Keep milestone code review todo as "in_progress"
     - Mark milestone implementation todo as "in_progress" (to show rework needed)
     - Spawn coder again with review feedback to fix issues
     - Continue coder → reviewer loop until milestone is approved
     - After 3 iterations, check with user but keep going

5. **Update Progress After Each Milestone**:
   - Both milestone implementation and code review todos should be marked "completed"
   - Ensure all milestone tasks are marked [x] in tasks.md
   - Show progress summary: "Milestone X of Y completed (implementation + review)"

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
- Suggest running `/spec/complete` to generate architecture documentation

## Important Guidelines

### Specs as Guiding Principles
- **DESIGN.MD IS THE BLUEPRINT** - All implementation must match it exactly
- Requirements define WHAT to build
- Design defines HOW to build it
- Tasks define the STEPS to build it
- Every line of code should trace back to the design document

### Implementation Process
- Work through milestones sequentially
- **Group related tasks into SMALL milestones (3-5 tasks ideal, 7 max)**
- Complete entire milestones before moving to review phase
- Each milestone must be approved before moving to the next
- NEVER give up on a milestone - keep iterating until it's complete
- Keep the user informed of progress (which milestone is being worked on, how far along it is, what milestones are left)

## Milestone Breakdown Examples

### Example 1: Language Server Protocol Implementation (~50 tasks)

**Bad Grouping (too large):**
```
- Milestone 1: Parser Implementation (tasks 1-15)
- Milestone 2: Diagnostic System (tasks 16-30)
- Milestone 3: Code Completion (tasks 31-50)
```

**Good Grouping (manageable chunks):**
```
- Milestone 1: Basic Parser Setup (tasks 1-3)
- Milestone 2: Token Recognition (tasks 4-7)
- Milestone 3: AST Node Types (tasks 8-11)
- Milestone 4: Expression Parsing (tasks 12-15)
- Milestone 5: Error Reporter Foundation (tasks 16-19)
- Milestone 6: Diagnostic Collection (tasks 20-23)
- ... and so on
```

### Example 2: E-commerce Feature (~30 tasks)

**Bad Grouping:**
```
- Milestone 1: Product Management (tasks 1-12)
- Milestone 2: Shopping Cart (tasks 13-24)
- Milestone 3: Checkout (tasks 25-30)
```

**Good Grouping:**
```
- Milestone 1: Product Model & Schema (tasks 1-3)
- Milestone 2: Product CRUD API (tasks 4-7)
- Milestone 3: Product Search/Filter (tasks 8-10)
- Milestone 4: Product Images (tasks 11-12)
- Milestone 5: Cart Session Management (tasks 13-15)
- Milestone 6: Add/Remove Cart Items (tasks 16-19)
- ... and so on
```

### Key Principles:
1. **Logical Cohesion**: Tasks that work on the same component/feature
2. **Dependency Order**: Earlier milestones provide foundation for later ones
3. **Review Scope**: What makes sense to review as a unit
4. **Time Boxing**: Aim for 1-2 hour implementation chunks
5. **Progress Visibility**: More milestones = more frequent progress updates

## Error Handling

- If requirements.md is missing: Stop and inform the user
- If tasks.md is missing: Stop and inform the user
- If a task repeatedly fails review: Escalate to user with details

## Handling Interrupted Sessions

When resuming implementation after interruption:

1. **ALWAYS run context initialization first** (Step 1)
2. **Trust codebase reality over documentation** - Code doesn't lie
3. **Update tasks.md to match actual state** before continuing
4. **Check for partial implementations**:
   - Incomplete functions with TODO comments
   - Missing error handling
   - Unfinished test cases
5. **Verify dependencies** - Earlier tasks may affect later ones
6. **Resume from last known good state** - Don't assume completion

### Example Recovery Flow:
```
User: Continue implementing the unified lexer
Assistant: I'll first check the actual implementation status...

[Spawns codebase-researcher]
Found that tasks 1-7 are fully implemented, task 8 is partial, tasks 9-15 not started.
Updating tasks.md to reflect true state...

[Updates tasks.md]
Now resuming from task 8 with proper context...
```

## Example Flow

```text
User: Implement the authentication feature
Assistant: I'll implement all tasks for the authentication feature using milestone-based approach.

Reading requirements and tasks...
Found 18 tasks, grouping into 6 smaller milestones:

[TodoWrite: Creates milestone tracking with implementation + review phases]
- Milestone 1: User Model Setup (tasks 1-3) [pending]
- Milestone 1: Code Review [pending]
- Milestone 2: Password Security (tasks 4-6) [pending]
- Milestone 2: Code Review [pending]
- Milestone 3: Session Management (tasks 7-10) [pending]
- Milestone 3: Code Review [pending]
- Milestone 4: Login/Logout API (tasks 11-13) [pending]
- Milestone 4: Code Review [pending]
- Milestone 5: Auth Middleware (tasks 14-15) [pending]
- Milestone 5: Code Review [pending]
- Milestone 6: Frontend Integration (tasks 16-18) [pending]
- Milestone 6: Code Review [pending]

Starting Milestone 1: User Model Setup...
[TodoWrite: Mark "Milestone 1: User Model Setup" as in_progress]
[Spawns coder for 3 user model tasks]
[TodoWrite: Mark "Milestone 1: Code Review" as in_progress]
[Spawns code-reviewer for milestone review]
✓ Milestone 1 approved!
[TodoWrite: Mark both milestone 1 todos as completed]

Progress: Milestone 1 of 6 completed (implementation + review)

Starting Milestone 2: Password Security...
[Continues through all milestones with visual todo tracking]
```
