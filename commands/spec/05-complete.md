---
description: Spec: Mark as Complete and Generate Living Documentation
allowed-tools: Read, Write, Edit, MultiEdit, Glob, Grep, LS, Bash, Task
---

# Spec: 05. Complete and Document

Mark a spec as complete and transform it into living documentation that reflects the actual implementation.

## Instructions

When the user wants to mark a spec as complete, follow these steps:

### 1. Verify Completion

- Read the tasks.md file to ensure all tasks are marked as completed
- If any tasks remain incomplete, inform the user and stop

### 2. Generate Architecture Documentation

- **Analyze the Actual Implementation**:
  - Use codebase-researcher agent to analyze the implemented code
  - Focus on the actual architecture, not the planned design
  - Document real patterns, components, and data flow
  - Include actual file paths and module structure
  - Note any deviations from the original design

- **Create architecture.md** with:
  - Mermaid diagrams
  - Overview of the implemented feature
  - Actual component structure and relationships
  - Real data flow and state management
  - Integration points
  - File structure and key modules
  - API endpoints or interfaces

### 3. Transform to Living Documentation

1. **Save architecture.md**:
   - Save the generated architecture documentation to `.claude/specs/{feature_name}/architecture.md`
   - This replaces the design.md with actual implementation details

2. **Clean up working files**:

   ```bash
   rm .claude/specs/{feature_name}/design.md
   rm .claude/specs/{feature_name}/tasks.md
   ```

3. **Final structure**:

   ```
   .claude/specs/{feature_name}/
   ├── requirements.md  (original requirements)
   └── architecture.md  (actual implementation)
   ```

### 4. Create Summary

Generate a brief summary that includes:

- Feature name
- Key components implemented
- Any notable decisions or changes from original design

## Architecture Documentation Template

```markdown
# {Feature Name} - Architecture

## Overview
[Brief description of what was actually built]

## Components

### Core Components
- **Component Name**: Purpose and location (file_path)
  - Key methods/functions
  - Dependencies
  - State management

### Supporting Modules
- List of utilities and helpers created
- Shared code or abstractions

## Data Flow
[How data actually flows through the system]

## Integration Points
- Existing systems integrated with
- APIs consumed or exposed
- Database connections
- External services

## Key Implementation Details

### Patterns Used
- Design patterns applied
- Coding conventions followed
- Architecture decisions

### State Management
- How state is managed
- Data persistence approach
- Caching strategies

### Error Handling (if applicable)
- Error boundaries
- Validation approach
- User feedback mechanisms

## Testing Coverage (if applicable)
- Test file locations (e.g., `tests/auth.test.ts`, `__tests__/user.spec.js`)
- Coverage areas (without implementation details)

## Future Considerations (if applicable)
- Known limitations
- Potential improvements
- Technical debt created
```

## Important Notes

- Focus on ACTUAL implementation, not planned design
- Include real file paths (without line numbers as they change frequently)
- Document any deviations from original plan
- Ensure documentation will help future developers understand the code
- Make the documentation a living reference that matches the codebase
- Try not to include too many things that will become outdated
