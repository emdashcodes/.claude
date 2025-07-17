---
description: Copy relevant details from the last response to clipboard
allowed-tools: Bash(pbcopy)
---

# Copy to Clipboard

Copy relevant details from the last response(s) to the user's clipboard.

## Usage

`/user:pbcopy`

## Instructions

1. **Identify Content**: Look at the last assistant response and extract the most relevant content
   - For code: Copy the code blocks
   - For plans: Copy the plan or todo list
   - For fixes: Copy the corrected text
   - For PRs: Copy the PR description/draft
   - For explanations: Copy the key points
   - Prefer markdown formatting for code and plans, with code nested in backticks

2. **Copy to Clipboard**: Use the bash command `pbcopy` to copy the content to the clipboard as plain text.

3. **Confirm**: Let the user know what was copied.

## Arguments

$ARGUMENTS
