---
description: Spec: Create Implementation Task List
allowed-tools: Bash, Read, Write, Edit, MultiEdit, Glob, Grep, LS, Task
---

# Spec: Create Implementation Task List

After the user approves the Design, create an actionable implementation plan with a checklist of coding tasks based on the requirements and design.

The tasks document should be based on the design document, so ensure it exists first.

## Automatic Quality Improvement Process

Before presenting the implementation plan to the user:

1. Generate initial task list based on design and requirements
2. Run spec-reviewer agent to validate the implementation plan:

   ```python
   # {full_context} includes: requirements, design, task list draft, codebase info, any user context
   Task(
       description="Review implementation plan",
       prompt="Review the tasks.md for {feature-name}. {full_context}. Focus on task atomicity, coverage, dependencies, and alignment with design. Save review to .claude/specs/{feature-name}/reviews/tasks-review.md (overwrite if exists)",
       subagent_type="spec-reviewer"
   )
   ```

3. Read the review and if issues are found, automatically fix them:
   - Address ALL CRITICAL issues
   - Fix IMPORTANT issues where clear guidance is provided
   - Keep track of MINOR issues to mention to user
4. If changes were made, run spec-reviewer again to verify fixes
5. Only present the cleaned-up, validated version to the user

## Constraints

- You MUST create spec files using the following path pattern: `.claude/specs/{feature_name}/tasks.md`
- You MUST return to the design step if the user indicates any changes are needed to the design
- You MUST return to the requirement step if the user indicates that we need additional requirements
- You MUST make sure ALL THREE spec files are present and in-sync
- You MUST create an implementation plan at the appropriate spec path
- You MUST format the implementation plan as a numbered checkbox list with a maximum of two levels of hierarchy:
  - Top-level items (like epics) should be used only when needed
  - Sub-tasks should be numbered with decimal notation (e.g., 1.1, 1.2, 2.1)
  - Each item must be a checkbox
  - Simple structure is preferred
- You MUST ensure each task item includes:
  - A clear objective as the task description that involves writing, modifying, or testing code
  - Additional information as sub-bullets under the task
  - Specific references to requirements from the requirements document (referencing granular sub-requirements, not just user stories)
- You MUST ensure that the implementation plan is a series of discrete, manageable coding steps
- You MUST ensure each task references specific requirements from the requirement document
- You MUST NOT include excessive implementation details that are already covered in the design document
- You MUST assume that all context documents (feature requirements, design) will be available during implementation
- You MUST ensure each step builds incrementally on previous steps
- You SHOULD prioritize test-driven development where appropriate in line with the current codebase's practices
- You MUST ensure the plan covers all aspects of the design that can be implemented through code
- You SHOULD NOT include any steps that cannot be implemented through code (i.e. manual testing)
- You SHOULD sequence steps to validate core functionality early through code
- You MUST ensure that all requirements are covered by the implementation tasks
- You MUST offer to return to previous steps (requirements or design) if gaps are identified during implementation planning or anything needs changed
- You MUST ONLY include tasks that can be performed by a coding agent (writing code, creating tests, etc.)
- You MUST NOT include tasks related to manual testing, deployment, performance metrics gathering, or other non-coding activities
- You MUST focus on code implementation tasks that can be executed within the provided development environment
- You MUST ensure each task is actionable by a coding agent by following these guidelines:
  - Tasks should involve writing, modifying, or testing specific code components
  - Tasks should specify what files or components need to be created or modified
  - Tasks should be concrete enough that a coding agent can execute them without additional clarification or instruction
  - Tasks should focus on implementation details rather than high-level concepts
  - Tasks should be scoped to specific coding activities (e.g., "Implement X function" rather than "Support X feature")
- You MUST explicitly avoid including the following types of non-coding tasks in the implementation plan:
  - User acceptance testing or user feedback gathering
  - Deployment to production or staging environments
  - Performance metrics gathering or analysis
  - Running the application to test end to end flows
  - User training
  - Business process changes or organizational changes
  - Marketing or communication activities
  - Any task that cannot be completed through writing, modifying, or testing code
- After updating the tasks document, you MUST ask the user IN CHAT "Do the tasks look good?"
- Do NOT ask questions in the tasks document
- You MUST make modifications to the tasks document if the user requests changes or does not explicitly approve.
- You MUST ask for explicit approval after every iteration of edits to the tasks document.
- You MUST NOT consider the workflow complete until receiving clear approval (such as "yes", "approved", "looks good", etc.).
- You MUST continue the feedback-revision cycle until explicit approval is received.
- You MUST stop once the task document has been approved.
- You MUST make sure that all three spec files are present and in-sync before finishing this step

## Final Comprehensive Review

After user approval of the implementation plan:

1. Run a final comprehensive spec review across all documents:

   ```python
   # {full_context} includes: ALL spec documents, codebase context, user requirements, approval history
   Task(
       description="Final spec review",
       prompt="Review the complete spec for {feature-name} (requirements.md, design.md, tasks.md). {full_context}. Check for cross-document consistency, completeness, and readiness for implementation. Save final review to .claude/specs/{feature-name}/reviews/final-review.md (overwrite if exists)",
       subagent_type="spec-reviewer"
   )
   ```

2. Read the final review and inform the user of the overall spec status
3. If the spec is APPROVED, celebrate with the user and note that implementation can begin
4. If issues are found, work with the user to address them in the appropriate document(s)

## Important Guidelines

**Important: This workflow is ONLY for creating design and planning artifacts. The actual implementation of the feature will be done through a separate workflow.**

- You MUST NOT attempt to implement the feature as part of this workflow
- You MUST clearly communicate to the user that this workflow is complete once all of the artifacts are created
-

**You MUST use the following specific instructions when creating the implementation plan:**

```
  Convert the feature design into a series of prompts for a code-generation LLM that will implement each step in a test-driven manner. Prioritize best practices, incremental progress, and early testing, ensuring no big jumps in complexity at any stage. Make sure that each prompt builds on the previous prompts, and ends with wiring things together. There should be no hanging or orphaned code that isn't integrated into a previous step. Focus ONLY on tasks that involve writing, modifying, or testing code.
```
