---
description: Convert Mermaid diagrams to images (PNG, SVG, PDF) using mermaid-cli
allowed-tools: Bash(mmdc:*), Read, LS, Glob
---

# Mermaid to Image Converter

Convert Mermaid diagrams to various image formats using the mermaid-cli tool

## Instructions

1. Parse the user's input to determine if they provided:
   - Diagram content in the previous context/discussion
   - A file path (check if it exists and ends with .mmd or .md)
   - Mermaid diagram content (if it starts with keywords like graph, flowchart, sequenceDiagram, etc.)
   - Additional info for output format and options

2. Set up variables:
   - Default output format: png
   - Default output name: mermaid-diagram-{SHORT_NAME_BASED_ON_CONTEXT}
   - Parse any additional options (theme, width, height, background, scale)

3. Handle the input:
   - If a file path is provided and exists, use it directly
   - If Mermaid content is provided, create a temporary .mmd file

4. Construct the mmdc command with appropriate options:
   - `-i` input file (temp file or provided file)
   - `-o` output file with appropriate extension
   - `-t` theme if specified
   - `-w` width (default 1600 for high resolution)
   - `-H` height (default 1200 for high resolution)
   - `-s` scale (default 2 for high resolution)
   - `-b` background color if specified
   - `-f` for PDF fit if PDF format

5. Execute the conversion and clean up:
   - Run the mmdc command
   - If using a temp file, clean it up
   - Verify the output file was created
   - Report success with the output filename

## Additional User Context

$ARGUMENTS
