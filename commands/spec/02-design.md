---
description: Spec: Create Design Document
allowed-tools: WebFetch, mcp__perplexity-mcp__perplexity_search_web, Read, Glob, Grep, Task, TodoRead, TodoWrite, LS, Write, Edit, MultiEdit, NotebookRead, NotebookEdit
---

# Spec: Create Design Document

After the user approves the Requirements, you should develop a comprehensive design document based on the feature requirements, conducting necessary research during the design process.

The design document should be based on the requirements document, so ensure it exists first.

## Research Methodology

- Create a research plan and track it with the TodoRead and TodoWrite tools
- Identify key research areas needed for the design:
  - External research: patterns, best practices, security considerations (use `researcher`)
  - Internal research: existing codebase patterns, similar implementations, conventions (use `codebase-researcher`)
- Spawn researcher agents to investigate each area:

  ```python
  # Example: Spawn research agents for different aspects - ALL IN ONE MESSAGE
  # {full_context} includes: requirements, feature description, codebase info, design constraints
  Task("Research authentication patterns", "Research modern authentication patterns for {feature-type}. {full_context}. Save to .claude/research/{feature-name}-design/", "researcher")
  Task("Research security best practices", "Research security considerations for {feature-type}. {full_context}. Save to .claude/research/{feature-name}-design/", "researcher")
  Task("Research performance optimization", "Research performance patterns for {feature-type}. {full_context}. Save to .claude/research/{feature-name}-design/", "researcher")
  Task("Analyze existing patterns", "Analyze how similar features are implemented in our codebase. {full_context}. Save to .claude/research/{feature-name}-design/", "codebase-researcher")
  ```

- **ALWAYS spawn research agents CONCURRENTLY in a SINGLE MESSAGE**
- Research agents will create comprehensive documentation in `.claude/research/{feature-name}-design/`
- Read and synthesize the research findings
- Reference specific research documents in your design decisions
- Cite research files using relative paths and [index] notation (e.g., `See: .claude/research/{feature-name}-design/authentication-patterns.md`)
- Cite URLs using [index] notation

When you or the sub agents use web search you SHOULD use the SIFT method:

- **Stop**: Pause before accepting information (ultrathink)
- **Investigate**: Research the source's credibility
- **Find**: Locate better/corroborating sources
- **Trace**: Follow information to its original source

## Automatic Quality Improvement Process

Before presenting the design to the user:

1. Generate initial design document based on requirements and research
2. Run spec-reviewer agent to validate the design:

   ```python
   # {full_context} includes: requirements, design draft, research findings, codebase patterns, any user context
   Task(
       description="Review design draft",
       prompt="Review the design.md for {feature-name}. {full_context}. Focus on technical feasibility, requirement coverage, and completeness. Save review to .claude/specs/{feature-name}/reviews/design-review.md (overwrite if exists)",
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

- You MUST create spec files using the following path pattern: `.claude/specs/{feature_name}/design.md`
- You MUST identify areas where research is needed based on the feature requirements
- You SHOULD spawn researcher agents to create comprehensive research documentation in `.claude/research/{feature-name}-design/`
- You MUST reference and cite the research files in your design document
- You MUST summarize key findings that will inform the feature design
- You MUST cite sources, including research documents, source files, and any relevant links
- You MUST create a detailed design document at the appropriate spec path
- You MUST incorporate research findings directly into the design process
- You MUST include the following sections in the design document:
  - Overview
  - Research Summary (with links to full research documents)
  - Architecture
  - Components and Interfaces
  - Data Models
  - Error Handling
  - Tests
- The Research Summary section should:
  - Briefly summarize key findings from each research document
  - Link to the full research files in `.claude/research/{feature-name}-design/`
  - Properly cite research files using [index] notation
  - Explain how research informed design decisions
- You SHOULD include diagrams or visual representations when appropriate (use Mermaid for diagrams if applicable)
- You MUST ensure the design addresses all feature requirements identified during the clarification process
- You SHOULD highlight design decisions and their rationales
- You SHOULD NOT suggest any patterns that are not a part of the codebase
- You MUST NOT include any future enhancements or anything not part of the requirements document
- You MAY ask the user for input on specific technical decisions during the design process
- After updating the design document, you MUST ask the user IN CHAT "Does the design look good? If so, we can move on to the implementation plan."
- You SHOULD NOT ask questions in the design document
- You MUST make modifications to the design document if the user requests changes or does not explicitly approve
- You MUST ask for explicit approval after every iteration of edits to the design document
- You MUST NOT proceed to the implementation plan until receiving clear approval (such as "yes", "approved", "looks good", etc.)
- You MUST continue the feedback-revision cycle until explicit approval is received
- You MUST incorporate all user feedback into the design document before proceeding
- You MUST offer to return to feature requirements clarification if gaps are identified during design
- You MUST verify that the design aligns with the latest version of requirements.md before asking for approval
- If requirements have changed since the design was created, you MUST update the design to match
- If the user requests changes to the design, you MUST keep the requirements document in sync
