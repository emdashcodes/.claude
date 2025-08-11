---
description: Generate technical design document from approved requirements
allowed-tools: Task, TodoWrite, Read, Bash, WebFetch, mcp__perplexity-mcp__perplexity_search_web
---

# Spec Workflow: Design

Generate design.md from approved requirements, conducting research to inform design decisions.

## Process

1. **Verify Requirements**:
   - Ensure requirements.md exists and is approved
   - Read ENTIRE requirements document thoroughly
   - Extract ALL technical details, constraints, and specifications
   - Identify ALL areas needing research (security, performance, patterns, etc.)

2. **Research Phase**:
   - Analyze requirements to identify EVERY aspect needing research
   - Create detailed research plan with TodoWrite
   - **CRITICAL**: Spawn ALL researcher agents CONCURRENTLY in ONE MESSAGE
   - Never spawn agents sequentially - always batch them together
   - Provide each agent with complete requirements and specific investigation areas
   - Request DETAILED reports with citations, examples, and recommendations
   - Receive comprehensive research summaries from all agents
   - Carefully read and synthesize ALL findings into design context

3. **Generate Design**:
   - Spawn spec-design agent with full context and research
   - Agent creates comprehensive design document
   - Design saved to `.claude/specs/{feature-name}/design.md`

4. **Review Cycle**:
   - Present design for human review
   - Make any requested changes
   - When approved, user can proceed to `/spec:workflow:tasks`

## Implementation

When invoked:

1. Check if requirements.md exists and status
2. Read the COMPLETE requirements document - every section, every detail
3. Extract and organize ALL context:
   - Every requirement and sub-requirement
   - All user constraints and preferences
   - Every technical specification mentioned
   - All integration points and dependencies
   - Performance and security requirements
   - Any examples or use cases provided
4. Identify ALL research needs and spawn researchers CONCURRENTLY:

```python
# CRITICAL: Spawn ALL research agents in ONE MESSAGE for concurrent execution
# NEVER spawn agents one at a time - always batch them together for performance
# Provide MAXIMUM DETAIL to each agent for comprehensive research

# For an authentication feature, you might spawn:
Task(
    "Research auth patterns",
    """Research modern authentication patterns for our {feature-type} feature.
    FULL CONTEXT: {full-requirements-content}
    Key aspects to investigate:
    - OAuth 2.0, SAML, OpenID Connect patterns
    - Token management (JWT, refresh tokens, session tokens)
    - Multi-factor authentication approaches
    - SSO implementation patterns
    - Security best practices and vulnerabilities
    Return DETAILED findings with:
    - Specific implementation recommendations
    - Pros/cons of each approach
    - Security considerations
    - Performance implications
    - All sources cited with [1], [2] notation""",
    "researcher"
)

Task(
    "Analyze existing auth",
    """Analyze our existing authentication implementation in detail.
    FULL CONTEXT: {full-requirements-content}
    Investigate:
    - Current auth patterns in use (files, functions, approaches)
    - Session management implementation
    - Token handling and storage
    - Security measures already in place
    - Integration points with other systems
    Return COMPREHENSIVE analysis with:
    - Specific file paths and line numbers
    - Current patterns we must maintain
    - Opportunities for improvement
    - Potential conflicts with new requirements
    - All codebase references cited""",
    "codebase-researcher"
)

# REMEMBER: All Task() calls above must be in a SINGLE message
# This ensures concurrent execution for maximum performance
# NEVER call Task() in separate messages for research agents
```

5. Receive DETAILED research reports from agents:
   - Read each complete report thoroughly
   - Preserve ALL citations and source references
   - Extract EVERY recommendation and pattern discovered
   - Note ALL pros/cons and trade-offs mentioned
   - Identify any conflicts between different recommendations
   - Compile ALL findings into comprehensive context
6. Spawn spec-design agent with COMPLETE CONTEXT including:
   - Full requirements document
   - Complete research reports (not summaries)
   - All user context and constraints
   - Complete project and codebase context
   - Every technical detail gathered

```python
Task(
    description="Generate design for {feature-name}",
    # CRITICAL: Give MAXIMUM CONTEXT including research findings
    prompt="""
    Feature: {feature-name}
    
    FULL REQUIREMENTS DOCUMENT:
    {full-requirements-content}
    
    DETAILED RESEARCH FINDINGS (complete agent reports with citations):
    
    === BEST PRACTICES RESEARCH ===
    {complete-best-practices-report-with-citations}
    
    === CODEBASE ANALYSIS ===
    {complete-codebase-analysis-with-file-references}
    
    === SECURITY RESEARCH ===
    {complete-security-findings-with-sources}
    
    === PERFORMANCE CONSIDERATIONS ===
    {complete-performance-research-with-benchmarks}
    
    === ADDITIONAL RESEARCH ===
    {any-other-research-reports}
    
    USER CONTEXT AND CONSTRAINTS:
    - All constraints: {detailed-user-constraints}
    - Technical specifications: {complete-technical-specs}
    - Exclusions: {all-user-exclusions}
    - Preferences: {user-implementation-preferences}
    - Non-functional requirements: {performance-security-scalability-needs}
    
    PROJECT CONTEXT (comprehensive):
    - Full codebase structure: {detailed-codebase-structure}
    - Complete technology stack: {all-frameworks-libraries-tools}
    - Architecture patterns in use: {detailed-architecture-patterns}
    - All existing integrations: {complete-integrations-list}
    - Testing approach: {testing-framework-patterns-coverage}
    - Deployment environment: {infrastructure-deployment-details}
    - Development workflow: {ci-cd-review-process}
    
    IMPORTANT INSTRUCTIONS:
    1. Incorporate ALL research findings into design decisions
    2. Preserve and reference all citations from research reports
    3. Create comprehensive design addressing ALL requirements
    4. Include: Overview, Architecture, Components, Data Models, Error Handling, Testing Strategy
    5. Ensure design aligns with codebase patterns from research
    6. Create design.md at: .claude/specs/{feature-slug}/design.md
    7. Make design decisions explicit with rationales based on research
    8. Include diagrams where helpful (use Mermaid)
    9. Cite sources using [1], [2] notation throughout the design
    
    Generate a technical design that bridges requirements to implementation.
    """,
    subagent_type="spec-design"
)
```

## Research Methodology

When conducting research:
- Use SIFT method for evaluating sources:
  - **Stop**: Pause before accepting information
  - **Investigate**: Research source credibility
  - **Find**: Locate corroborating sources
  - **Trace**: Follow to original source
- Research agents return DETAILED reports with:
  - Complete findings, not just summaries
  - All sources and citations
  - Specific examples and code samples
  - Pros/cons for each approach
  - Clear recommendations with rationales
- Synthesize multiple research perspectives comprehensively

## CRITICAL: Concurrent Research Execution

**ALL research agents MUST be spawned in a SINGLE MESSAGE:**
- Identify ALL research needs first
- Create ALL Task() calls in one message
- NEVER spawn research agents sequentially
- This ensures parallel execution for maximum performance
- Example: If you need 5 research topics, all 5 Task() calls go in ONE message

## CRITICAL: Information Completeness

**NEVER summarize or abbreviate when passing context between agents:**
- Pass FULL requirements document, not excerpts
- Include COMPLETE research reports, not summaries
- Provide ALL constraints and specifications
- Share ENTIRE codebase context discovered
- Include EVERY technical detail mentioned by user

The quality of the design depends on the completeness of information provided.

## Example Flow

```text
User: /spec:workflow:design
Assistant: I'll generate a technical design from your approved requirements.

[Reads requirements.md to understand the feature]
[Creates research plan with TodoWrite]

Now spawning ALL research agents concurrently:
[Single message containing:]
  - Task("Research auth patterns", "...", "researcher")
  - Task("Research security best practices", "...", "researcher")  
  - Task("Research performance patterns", "...", "researcher")
  - Task("Analyze existing auth code", "...", "codebase-researcher")
  - Task("Research session management", "...", "researcher")
[All agents execute in parallel]

[Receives and synthesizes detailed research reports]
[Spawns spec-design agent with complete context]

Design document has been generated at: .claude/specs/authentication/design.md

The design incorporates research on:
- Modern authentication patterns and best practices
- Security considerations and recommendations
- Our existing codebase patterns and conventions

Please review the design. When approved, use:
- `/spec:workflow:tasks` to generate implementation tasks
```

## Prerequisites

- Requirements must exist at `.claude/specs/{feature-name}/requirements.md`
- Requirements should be in "approved" status
- User should have reviewed and approved the requirements

## Error Handling

- If requirements.md is missing: Inform user to create requirements first
- If requirements not approved: Ask if user wants to approve them now
- If research fails: Continue with available information, note gaps