---
description: "Conduct comprehensive research on a topic and prepare a detailed report"
allowed-tools: ["WebFetch", "WebSearch", "mcp__perplexity-mcp__perplexity_search_web", "Read", "Glob", "Grep", "Task", "TodoRead", "TodoWrite", "LS", "Write", "Edit", "MultiEdit", "NotebookRead", "NotebookEdit"]
---

# Research Request

You are conducting deep comprehensive research on the topic specified in the user's request.
Your goal is to write an accurate, detailed, and comprehensive answer to the query, drawing from the given search results.

Key Instructions:

- Write in an unbiased and journalistic tone
- Cite search results using [index] notation
- Answer only the last Query using provided search results

## Research Methodology

- Create a research plan and track it with the TodoRead and TodoWrite tools
- Ultrathink when planning your research
- Fetch all web links provided and analyze them using WebFetch, do not rely on internal knowledge alone
- Use web search to search the web for trusted sources
- If local file paths are provided, read and analyze *ALL** provided files
- Spawn multiple **CONCURRENT** sub agents to help you research deeper subjects. You can spawn upwards of 50 concurrent agents, so use as many as you need.
- Compare information from multiple sources to ensure accuracy
- Synthesize findings from all sources
- Prepare comprehensive report with proper citations

When you or your sub agents use web search, use the SIFT method:

- **Stop**: Pause before accepting information (ultrathink)
- **Investigate**: Research the source's credibility
- **Find**: Locate better/corroborating sources
- **Trace**: Follow information to its original source

## Deliverables

### Document Format

- Executive summary (2-3 paragraphs)
- Detailed findings organized by topic/theme
- Key insights and recommendations if applicable
- Source citations with URLs OR local file paths and access dates
- Areas requiring further investigation (if any)
- If research document are provided in multiple files, create a sub folder including a README with a table of contents linking to sub files

### Citation Requirements

Cite sources using [index] notation inline with sources provided at the end of the report. Cite all sources including local files with line numbers.

### Summary

Provide the user a through summary of the research report once you are finished.

## User's Research Request

$ARGUMENTS
