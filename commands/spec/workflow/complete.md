---
description: Spec Completion - Mark as Complete and Generate Living Documentation
allowed-tools: Read, Write, Edit, MultiEdit, Glob, Grep, LS, Bash, Task
---

# Spec: Completion and Documentation

Mark a spec as complete and transform it into living documentation that reflects the actual implementation.

## Instructions

When the user wants to mark a spec as complete, follow these steps:

### 0. Find Available Specs

Check what specs are available:
!`~/.claude/helpers/list-specs.sh`

If the user doesn't specify which spec, list available options and ask which one to complete.

### 1. Verify Completion

- Read the tasks.md file to ensure all tasks are marked as completed
- If any tasks remain incomplete, inform the user and stop

### 2. Generate Architecture Documentation

- **Analyze the Actual Implementation**:
  - Use codebase-researcher agent to analyze the implemented code
  - Focus on high-level concepts and patterns
  - Document architectural decisions and approach
  - Note any deviations from the original requirements

- **Create architecture.md** with:
  - High-level conceptual overview
  - Key architectural patterns used
  - Major design decisions
  - Integration approach
  - Behavioral characteristics

### 3. Transform to Living Documentation

1. **Save architecture.md**:
   - Save the generated architecture documentation to `.claude/specs/{feature_name}/architecture.md`
   - This documents the actual implementation details

2. **Update requirements.md status**:
   - Update the frontmatter `status: completed`
   - Add completion date if desired

3. **Final structure**:

   ```text
   .claude/specs/{feature_name}/
   ├── plan.md          (with status: accepted)
   ├── requirements.md  (with status: completed)
   ├── tasks.md         (all tasks marked complete)
   └── architecture.md  (actual implementation)
   ```

### 4. Update TODO.md (if exists)

**Only if a TODO.md file exists in the project root:**

1. **Check for TODO.md**:
   - Look for `TODO.md` in the project root directory
   - If it doesn't exist, skip this step entirely

2. **Find the corresponding section**:
   - Search for a section that matches the feature name or related functionality
   - Look for checkbox items that correspond to the completed feature

3. **Mark items as completed**:
   - Change `- [ ]` to `- [x]` for items related to the completed feature
   - Update any subsections or related tasks as appropriate
   - Be conservative - only mark items you're confident are completed

4. **Preserve existing structure**:
   - Don't add new sections or reorganize the TODO.md
   - Only update existing checkbox states
   - Keep all other content unchanged

### 5. Create Summary

Generate a brief summary that includes:

- Feature name
- Key components implemented
- Any notable decisions or changes from original requirements
- Whether TODO.md was updated (if applicable)

## Architecture Documentation Template

```markdown
# {Feature Name} - Architecture

## Overview
[High-level description of the feature and its purpose]

## Architectural Approach
[Key design decisions and why they were made]

## Core Concepts
[Major abstractions and patterns introduced]

## Behavioral Model
[How the feature behaves from a user perspective]

## Integration Strategy
[How this feature fits into the larger system]

## Key Interfaces
[Public APIs or contracts that define the feature]

## Design Trade-offs
[Major decisions and their rationale]

## Future Evolution
[How this architecture supports future growth]
```

## Important Notes

- Keep documentation at a conceptual level
- Code is the source of truth for implementation details
- Focus on the "why" rather than the "how"
- Document patterns and approaches, not specific files
- Make documentation that ages well with code changes