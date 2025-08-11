---
description: Generate requirements from a discussion, plan, or feature description
allowed-tools: Task, TodoWrite
---

# Spec Workflow: Requirements

Generate requirements.md from a feature discussion, plan, or feature description

## Process

1. **Gather Context**:
   - Ask user for feature name if not provided
   - Get any additional context about the feature
   - Understand any constraints or specific requirements

2. **Generate Requirements**:
   - Spawn spec-requirements agent with feature description
   - Agent creates EARS-formatted requirements
   - Requirements saved to `.claude/specs/{feature-name}/requirements.md`

3. **Review Cycle**:
   - Present requirements for human review
   - Make any requested changes
   - When approved, user can proceed to:
     - `/spec:workflow:design` to create technical design document
     - `/spec:workflow:tasks` to generate implementation tasks (if design exists)
     - Or directly to `/spec:workflow:implement` if all artifacts exist

## Implementation

When invoked:

1. Ask for feature name and description if not provided
2. Create appropriate spec directory structure
3. Spawn spec-requirements agent with MAXIMUM context:

```python
Task(
    description="Generate requirements for {feature-name}",
    # CRITICAL: Give MAXIMUM CONTEXT to generate comprehensive requirements. Example below.
    prompt="""
    Feature: {feature-name}
    Feature Description: {feature-description}

    Additional Context Provided by User:
    - Constraints: {user-constraints}
    - Specific requirements: {user-specific-requirements}
    - Technical details: {user-technical-details}
    - Exclusions: {user-exclusions}
    - Environment details: {environment-details}
    - Related systems/integrations: {related-systems}
    - Performance requirements: {performance-requirements}
    - Security requirements: {security-requirements}
    - Any other user-provided context: {additional-context}

    Project Context:
    - Codebase structure: {codebase-structure}
    - Existing patterns/conventions: {existing-patterns}
    - Technology stack: {tech-stack}
    - Testing approach: {testing-approach}

    IMPORTANT INSTRUCTIONS:
    1. FIRST: Research the codebase thoroughly to understand:
       - Project vision, goals, and design philosophy (README, docs)
       - Existing patterns and architectural decisions
       - Similar features and their implementation approach
       - Technology stack and dependencies
    2. Honor ALL user constraints and exclusions
    3. Use ALL provided context to create comprehensive requirements
    4. Reference specific technical details in acceptance criteria
    5. Create requirements.md at: .claude/specs/{feature-slug}/requirements.md
    6. Include all edge cases and considerations from the context
    7. Ensure requirements align with discovered codebase patterns and vision

    The agent will research the codebase FIRST before generating requirements to ensure
    full alignment with the project's vision and existing patterns.
    """,
    subagent_type="spec-requirements"
)
```

## Examples

```
User: /spec:workflow:requirements
Assistant: What feature would you like to create requirements for?

User: A user notification system
Assistant: Can you provide more details about the notification system?

User: It should support email, SMS, and in-app notifications with user preferences
Assistant: [Spawns spec-requirements agent to generate formal requirements]
```
