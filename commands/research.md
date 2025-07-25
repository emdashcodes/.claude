---
description: Complete comprehensive deep research
allowed-tools: Task, mcp__perplexity-mcp__perplexity_search_web, Read, Glob, Grep, Task, TodoWrite, LS
---

# Deep Research

Invokes the researcher agent to conduct comprehensive research on the specified topic(s).

## Instructions

Parse the user's input and identify research angles:

- **ALWAYS think in terms of multiple concurrent agents**
- Even for a "single" topic, consider breaking it into multiple research angles
- For explicitly multiple topics (semicolons, "and", or lists), spawn agents for each
- **ALWAYS SPAWN AGENTS CONCURRENTLY IN A SINGLE MESSAGE**
- If necessary, do an initial search to gather more context before spawning agents

Process:

1. Create a master folder for the research theme
2. **Spawn multiple research-analyst agents concurrently** for different angles/topics
3. Each agent handles its own research independently (and can spawn its own sub-agents)
4. Create a master synthesis report combining all findings

### Research Execution (Always Multiple Agents)

Even for a single topic, spawn multiple agents for different angles.

Provide as much context as possible from the user request and your understanding of the research topic to the sub-agents.

```python
# Example: User asks "Research React state management"
# Break into multiple research angles - ALL IN ONE MESSAGE:
Task("Research technical aspects", "Research React state management technical implementation and architecture.  {full_context}. Save to .claude/research/react-state-management/technical-analysis/", "research-analyst")
Task("Research best practices", "Research React state management patterns and best practices. {full_context}. Save to .claude/research/react-state-management/best-practices/", "research-analyst")
Task("Research performance", "Research performance implications of different React state management approaches. {full_context}. Save to .claude/research/react-state-management/performance/", "research-analyst")

# If you come across code repositories, you can also clone a repository to `.claude/research/.scratch/` and then spawn **CONCURRENT** `codebase-research` agents for deep code analysis across local source code repos
Task("Analyze the state implementation", "Research the local state design of the current codebase. {full_context}. Save to .claude/research/react-state-management/local-implementation/", "codebase-researcher")
```

### Multiple Topic Research

**CRITICAL: ALL RESEARCH AGENTS MUST BE SPAWNED CONCURRENTLY IN A SINGLE MESSAGE!**

1. First, create a master research folder with a descriptive name
2. **SPAWN ALL RESEARCH AGENTS CONCURRENTLY** - Use multiple Task invocations in a **SINGLE RESPONSE**
3. After all agents complete, create a master report that:
   - Synthesizes findings across all topics
   - Identifies common themes and patterns
   - Highlights contrasts and comparisons
   - Provides consolidated recommendations
   - Links to individual topic reports

**NEVER spawn agents sequentially - ALWAYS spawn them CONCURRENTLY for maximum performance!**

Example structure for multiple topics:

```
.claude/research/
├── authentication-comparison/           # Master folder
│   ├── README.md                       # Master synthesis report
│   ├── oauth2-implementation/          # Individual topic
│   ├── jwt-best-practices/            # Individual topic
│   └── webauthn-adoption/             # Individual topic
```

For the master report, analyze all sub-reports and create:

- Executive summary across all topics
- Comparative analysis section
- Common patterns and themes
- Consolidated recommendations
- Links to detailed individual reports
- Citations

## Examples

**Single topic input:** "Modern authentication patterns"

- Break into angles: implementation, security, best practices, comparisons
- Spawn 4+ concurrent agents for comprehensive coverage

**Multiple topics input:** "OAuth2 implementation; JWT best practices; WebAuthn adoption"

- Spawn agents for each topic AND consider angles within each
- Could result in 9-12 concurrent agents for thorough research

**Listed topics input:** "Research 1) React performance optimization 2) Bundle size reduction 3) Code splitting strategies"

- Each numbered topic gets multiple agents for different angles
- Could result in 9-15 concurrent agents for complete analysis

**Always optimize for parallelism and comprehensive coverage!**

## Master Synthesis Template

After all agents complete, create `.claude/research/{master-topic-slug}/README.md` with:

```markdown
# Research Synthesis: {Master Topic Name}

## Executive Summary
[Cross-topic insights and key findings]

## Individual Research Topics
- [Topic 1](./topic-1-slug/README.md)
- [Topic 2](./topic-2-slug/README.md)
- [Topic 3](./topic-3-slug/README.md)

## Comparative Analysis
[Compare and contrast findings across topics]

## Common Themes
[Patterns that emerged across multiple topics]

## Consolidated Recommendations
[Synthesized recommendations based on all research]

## Conclusion
[Final thoughts tying everything together]

## Citations
[List of all citations used in the research]
```

## User Request

$ARGUMENTS
