---
description: Convert an approved plan into a full spec with requirements and tasks
allowed-tools: Read, Write, Edit, MultiEdit, Glob, Grep, LS, Task
---

# Plan to Spec Conversion

This command initiates the spec workflow from an approved plan, generating requirements and tasks through the automated spec review process.

## Prerequisites

- An approved plan.md file must exist in a spec folder
- The plan status must be "approved" in the frontmatter

## Process

### 1. Verify Plan Status

First, locate and verify the plan file:
- Check if a spec folder and plan.md exist
- Verify the plan status is "approved"
- If not approved, inform the user to approve the plan first

### 2. Generate Requirements

Once plan is verified:

1. **Spawn Requirements Agent**:
   ```python
   Task(
       description="Generate requirements from plan",
       prompt=f"Generate requirements.md for the spec at {spec_path}. Read the approved plan.md and create comprehensive EARS-formatted requirements. Follow the spec requirements format exactly.",
       subagent_type="general-purpose"
   )
   ```

2. **Run Spec Reviewer**:
   ```python
   Task(
       description="Review generated requirements",
       prompt=f"Review the requirements.md in {spec_path}. Focus on EARS compliance, completeness, and clarity. Return specific feedback.",
       subagent_type="spec-reviewer"
   )
   ```

3. **Present to User**:
   - Show the reviewed requirements
   - Ask for approval or modifications
   - Iterate until user approves

### 3. Generate Tasks

After requirements approval:

1. **Spawn Task Generation Agent**:
   ```python
   Task(
       description="Generate implementation tasks",
       prompt=f"Generate tasks.md for the spec at {spec_path}. Read both plan.md and requirements.md to create detailed, actionable implementation tasks.",
       subagent_type="general-purpose"
   )
   ```

2. **Run Spec Reviewer**:
   ```python
   Task(
       description="Review implementation tasks",
       prompt=f"Review the tasks.md in {spec_path}. Ensure all requirements have corresponding tasks and tasks are properly structured.",
       subagent_type="spec-reviewer"
   )
   ```

3. **Final Validation**:
   - Run a final consistency check across all documents
   - Present the complete spec to the user
   - Get final approval

### 4. Complete Spec Setup

Once approved:
- Update plan.md status to indicate spec is ready
- Create scratch folder for implementation phase
- Inform user that implementation can begin

## Usage Notes

- This command bridges the gap between planning and specification
- It ensures all specs go through proper review before implementation
- The user has final say at each approval stage
- All generated files follow the established spec format

## Error Handling

- If plan is not approved, guide user to approve it first
- If agents fail, provide clear error messages
- Always preserve user edits during iterations
- Allow user to manually edit files between agent runs