---
description: Spec: Create Design Document
allowed-tools: WebFetch, mcp__perplexity-mcp__perplexity_search_web, Read, Glob, Grep, Task, TodoRead, TodoWrite, LS, Write, Edit, MultiEdit, NotebookRead, NotebookEdit, Bash
---

# Spec: Create Design Document

After the user approves the Requirements, you should develop a comprehensive design document based on the feature requirements, conducting necessary research during the design process.

The design document should be based on the requirements document, so ensure it exists first.

## Research Methodology

- Create a research plan and track it with the TodoRead and TodoWrite tools
- Ultrathink when planning your research
- Fetch all web links provided and analyze them using WebFetch, do not rely on internal knowledge alone
- Use web search to search the web for trusted sources
- If local file paths are provided, read and analyze *ALL** provided files
- Spawn multiple **CONCURRENT** sub agents to help you research
- You can spawn upwards of 100 **CONCURRENT** agents so use them as needed
- Sub agents can also be activated with `ultrathink`.
- Sub agents SHOULD NOT write any files
- Compare information from multiple sources to ensure accuracy
- Synthesize findings from all sources
- Prepare comprehensive report with proper citations
- If sources come from Perplexity or task agent research, **DO NOT** just cite the agents themselves. You **MUST** provide the sources (URLs, files) provided to you by Perplexity and the sub agents. Ask all sub agents to cite their sources as well.

When you or your sub agents use web search, use the SIFT method:

- **Stop**: Pause before accepting information (ultrathink)
- **Investigate**: Research the source's credibility
- **Find**: Locate better/corroborating sources
- **Trace**: Follow information to its original source

## Constraints

- You MUST create spec files using the following path pattern: `.claude/specs/{feature_name}/design.md`
- You MUST identify areas where research is needed based on the feature requirements
- You MUST conduct research and build up context in the conversation thread
- You SHOULD NOT create separate research files, but instead use the research as context for the design and implementation plan
- You MUST summarize key findings that will inform the feature design
- You MUST cite sources, including source files and any relevant links
- You MUST create a detailed design document at the appropriate spec path
- You MUST incorporate research findings directly into the design process
- You MUST include the following sections in the design document:
  - Overview
  - Architecture
  - Components and Interfaces
  - Data Models
  - Error Handling
  - Testing Strategy
- You SHOULD include diagrams or visual representations when appropriate (use Mermaid for diagrams if applicable)
- You MUST ensure the design addresses all feature requirements identified during the clarification process
- You SHOULD highlight design decisions and their rationales
- You MUST NOT include any future enhancements or anything not part of the requirements document
- You MAY ask the user for input on specific technical decisions during the design process
- After updating the design document, you MUST ask the user IN CHAT "Does the design look good? If so, we can move on to the implementation plan."
- You MUST make modifications to the design document if the user requests changes or does not explicitly approve
- You MUST ask for explicit approval after every iteration of edits to the design document
- You MUST NOT proceed to the implementation plan until receiving clear approval (such as "yes", "approved", "looks good", etc.)
- You MUST continue the feedback-revision cycle until explicit approval is received
- You MUST incorporate all user feedback into the design document before proceeding
- You MUST offer to return to feature requirements clarification if gaps are identified during design
- You MUST verify that the design aligns with the latest version of requirements.md before asking for approval
- If requirements have changed since the design was created, you MUST update the design to match
- If the user requests changes to the design, you MUST keep the requirements document in sync
