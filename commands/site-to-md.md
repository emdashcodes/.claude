---
description: Download and convert website content to markdown using trafilatura
allowed-tools: Bash(*), LS, Write, Edit
---

# Site to Markdown Converter

Download and convert website content to clean markdown format using `trafilatura`.

## User Context

```
$ARGUMENTS
```

## Instructions

- Extract URL and output directory from the user's context
- Make the output directory if it doesn't exist
- Use `trafilatura` to download and convert website content to markdown format:
`trafilatura --explore <url> --markdown --with-metadata -o <output-dir>`
- Check what was downloaded and count files
- Parse file content to extract page titles and rename files with meaningful `.md` filenames based on content
