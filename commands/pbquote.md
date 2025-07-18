---
description: Copy content from the last response formatted as block quotes for replying
allowed-tools: Bash(pbcopy)
---

# Copy as Block Quote

Copy relevant details from the last response(s) to the clipboard formatted with `>` for easy replying/quoting.

## Instructions

1. **Identify Content**: Look at the last assistant response and extract the most relevant content
   - For code: Copy the code blocks
   - For plans: Copy the plan or todo list
   - For fixes: Copy the corrected text
   - For PRs: Copy the PR description/draft
   - For explanations: Copy the key points
   - Prefer markdown formatting for code and plans, with code nested in backticks

2. **Format as Block Quote**: Prefix each line with `> ` to create blockquotes for easy replying

3. **Copy to Clipboard**: Use the bash command `pbcopy` to copy the formatted content to the clipboard.

4. **Confirm**: Let the user know what was copied in block quote format.

## Additional User Context

$ARGUMENTS
