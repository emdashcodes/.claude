# emdashcodes/.claude

This is a Claude Code configuration repository - like dotfiles but for AI.
It includes custom commands, automated hooks, and a smart wrapper script.

Share, fork, copy parts of, and customize this configuration to build your own setup based on your own preferences.

## Components

- **Custom Slash Commands** - Git operations, research, proofreading, and utility tools
- **Automation Hooks** - Smart GitHub/Reddit fetching and commit message enforcement
- **Smart Wrapper** - Auto-injects custom system prompt for personalized AI behavior
- **Settings** - Personal Claude Code settings and configurations

## Repository Structure

```txt
.claude/
├── README.md              # This file
├── CLAUDE.md              # Main Claude Code memory/instructions
├── EXAMPLE-PROMPT.md      # Auto-injected system prompt template for others to customize (copy to PROMPT.md)
├── config/                # Configuration files directory
├── settings.json          # Claude Code configuration
├── commands/              # Custom slash commands
├── hooks/                 # Automation hooks
├── bin/                   # Additional utility scripts (add to your PATH)
└── local/
    └── claude             # Smart wrapper script
```

## Documentation

### Smart Wrapper (`local/claude`)

The wrapper enhances the Claude Code command (`claude`) with multiple additional features:

#### Auto System Prompt Injection

When you run interactive Claude commands (`claude`, `claude -c`, `claude -r`),
the wrapper automatically appends your `PROMPT.md` content using `--append-system-prompt`.

- This gives Claude a custom personality and instructions. Think of it as your personal AI configuration file.
- This is passed as part of the system prompt and is different from context loaded via CLAUDE.md.
- If an existing `--append-system-prompt` is provided, the two will be merged.
- This does not run for scripts (`claude -p ...`).

#### Permissions Override

- Set `CLAUDE_DANGEROUSLY_SKIP_PERMISSIONS=1` to automatically add `--dangerously-skip-permissions` flag
- Applies to all Claude Code invocations (interactive, continue, resume, and scripting modes)
- Use with caution - bypasses Claude Code's security restrictions

## Automation Hooks

The `hooks/` directory contains automation scripts that enhance Claude Code workflows. These hooks are triggered automatically by [Claude Code's hook system](https://docs.anthropic.com/en/docs/claude-code/hooks).

### `github-fetch.sh`

Intercepts `WebFetch` calls to GitHub URLs and uses `gh` CLI instead for better reliability and authentication.

**Features:**

- Supports GitHub.com and GitHub Enterprise instances
- Fetches PRs, issues, files, commits, releases, workflows, and profiles
- Smart diff truncation with instructions for full diffs
- Configurable via `config/github-config.json` for enterprise domains and proxy settings

### `reddit-fetch.sh`

Intercepts `WebFetch` calls to Reddit URLs and retrieves content via Reddit's JSON API.

**Features:**

- Fetches posts with comments, crossposts, and external links
- Configurable comment/post limits (`MAX_COMMENTS=10`, `MAX_POSTS=10`)
- Detects external links and suggests fetching them

### `git-commit.sh`

Enforces commit message standards when using `git commit` via Bash tool.

**Features:**

- Requires conventional commit prefixes: `feat:`, `fix:`, `docs:`, etc.
- Enforces 75 character max length
- Blocks multi-line messages
- Blocks `-f` and `--no-verify` flags (configurable via `ALLOW_FORCE_COMMIT=true`)

**Example:**

```bash
# Valid
git commit -m "feat: add user authentication"

# Invalid
git commit -m "Added feature"  # No prefix
```

## Slash Commands

The `commands/` directory contains custom slash commands that extend Claude Code with specialized workflows.

### Git Commands (`/git/*`)

- **`/git/create-commit`**: Creates git commits with proper formatting and conventional commit prefixes
- **`/git/create-pr`**: Creates comprehensive pull requests with generated titles, summaries, and test plans
- **`/git/review-pr`**: Reviews pull requests with detailed feedback on code quality and potential issues
- **`/git/update-pr`**: Updates existing PRs with recent commits while maintaining PR description format

### Utility Commands

- **`/proofread`**: Professional proofreading and editing with grammar, flow, and clarity improvements
- **`/research`**: Comprehensive research with Perplexity integration, source validation, and detailed reporting

### Tools (`/tools/*`)

- **`/tools/mermaid-to-image`**: Converts Mermaid diagrams to PNG, SVG, or PDF images
- **`/tools/pbcopy`**: Copies code blocks and content from responses to clipboard
- **`/tools/pbquote`**: Copies content formatted as block quotes for replies
- **`/tools/site-to-md`**: Downloads and converts websites to markdown using trafilatura

