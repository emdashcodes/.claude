---
description: "Download and convert website content to markdown using trafilatura"
allowed-tools: ["Bash", "LS", "Write", "Edit"]
---

# Site to Markdown Converter

Download and convert website content to clean markdown format using trafilatura.

## Usage

```bash
/site-to-md <url> [output-directory]
```

## Arguments

- `url` - The website URL to download (required)
- `output-directory` - Directory to save markdown files (optional, defaults to site name)

## Features

- **Full Site Exploration**: Uses trafilatura's `--explore` mode for comprehensive crawling
- **Clean Markdown**: Extracts content as clean markdown format with metadata
- **Intelligent Renaming**: Analyzes downloaded content to create meaningful filenames based on page titles
- **Includes Metadata**: Adds page titles, URLs, and dates to output files
- **Automatic Directory Creation**: Creates output directory if it doesn't exist
- **Progress Feedback**: Shows download progress and final results with file renaming summary

## Examples

```bash
# Download Claude Code documentation
/site-to-md https://docs.anthropic.com/en/docs/claude-code/ claude-code-docs

# Download to auto-named directory
/site-to-md https://example.com/docs/

# Download from sitemap
/site-to-md https://example.com/sitemap.xml
```

## Implementation

The command will:

1. **Parse Arguments**: Extract URL and optional output directory
2. **Create Directory**: Make output directory if it doesn't exist
3. **Download Content**: Execute `trafilatura --explore <url> --markdown --with-metadata -o <output-dir>`
4. **Analyze Results**: Check what was downloaded and count files
5. **Rename Files**: Parse file content to extract page titles and rename files with meaningful `.md` filenames based on content

## User Request

$ARGUMENTS