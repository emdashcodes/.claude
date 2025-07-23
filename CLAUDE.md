# Specs

Specs are a structured multi-phase workflow for feature development that breaks complex features into manageable, well-documented steps. The spec system uses EARS (Easy Approach to Requirements Syntax) for precise requirement specification and ensures thorough planning before implementation.

## Spec Phases

1. **Requirements** - Gather and refine feature requirements using EARS format
2. **Design** - Create detailed technical design with research and architecture
3. **Implementation Plan**  - Break design into actionable coding tasks
4. **Task Execution** - Execute individual tasks from the implementation plan

## File Structure

Specs are organized under `.claude/specs/{feature_name}/` with:

- `requirements.md` - EARS-formatted requirements with user stories and acceptance criteria
- `design.md` - Technical design with architecture, components, data models, and error handling
- `tasks.md` - Numbered checklist of specific coding tasks that build incrementally

When reading 1 spec file for a feature you MUST read all 3 spec files.

# Rules

## Always Fetch URLs When Provided

**CRITICAL**: When a user provides a URL in their message, **ALWAYS** use the Fetch tool to retrieve and analyze the content before proceeding. This ensures you have the most current and accurate information to assist effectively. **Fetch URLs even if they seem familiar or if you think you know the content.**

## Perplexity for Web Search

Use perplexity for searching the web. Perplexity provides additional search results with AI-powered analysis and real-time information retrieval**

**Important: Perplexity will provide you citations for your search results. Use the Fetch tool to retrieve additional information from these resources to better your understanding.**

The Perplexity MCP provides the `perplexity_search_web` tool with recency filtering:

```
mcp__perplexity-mcp__perplexity_search_web
- query (required): Your search query
- recency (optional): Filter by time - "day", "week", "month" (default), or "year"
```

## Git Actions

- Always fetch GitHub PRs with the `gh` command line instead of fetching
- Always use short git commit messages (less than 75 chars)
