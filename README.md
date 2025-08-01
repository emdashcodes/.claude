# emdashcodes/.claude

This is a Claude Code configuration repository - like dotfiles but for AI.
It includes custom commands, automated hooks and workflows, Obsidian integration, and other utilities.

Share, fork, copy parts of, and customize this configuration to build your own setup based on your own preferences.

## Components

- **Custom Slash Commands** - Specialized commands for task management, research, git operations, and more
- **Automation Hooks** - Automated workflows powered by Claude Code's hook system
- **Smart Wrapper** - Auto-injects additional system prompt + optional menu mode for session selection
- **Utility Scripts** - Additional scripts to help with common workflows
- **Obsidian Integration** - Includes specific commands for working with Obsidian vaults
- **Settings** - My personal settings for Claude Code

## Repository Structure

```txt
.claude/
├── README.md              # This file
├── CLAUDE.md              # Main Claude Code memory/instructions
├── EXAMPLE-PROMPT.md      # Auto-injected system prompt template for others to customize (copy to PROMPT.md)
├── example.vault.json     # Example vault configuration (copy to vault.json)
├── settings.json          # Claude Code configuration
├── commands/              # Custom slash commands
├── hooks/                 # Automation hooks
├── bin/                   # Additional utility scripts (add to your PATH)
│   └── claude-sysinfo     # System info utility for secure command permissions
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

#### Menu Mode (off by default)

- Set `CLAUDE_USE_MENU=1` to show interactive menu for plain `claude` commands
- Choose between: Start new / Resume previous / Continue last conversation
- Only affects bare `claude` - all other commands work normally

#### Permissions Override

- Set `CLAUDE_DANGEROUSLY_SKIP_PERMISSIONS=1` to automatically add `--dangerously-skip-permissions` flag
- Applies to all Claude Code invocations (interactive, continue, resume, and scripting modes)
- Use with caution - bypasses Claude Code's security restrictions

## Obsidian Integration

The `vault.json` file configures paths to your knowledge vault. These paths are provided to specific Claude Code commands to load relevant files:

- `commands/session-start.md`: Begin a new session
- `commands/session-start-task.md`: Start a session with a specific task
- `commands/session-end.md`: Close a session with proper documentation

### Setup

1. Copy the example configuration:

   ```bash
   cp example.vault.json vault.json
   ```

2. Edit `vault.json` to match your vault structure:

   ```json
   {
     "entries_path": "~/MyNotes/Daily",
     "sessions_path": "~/MyNotes/Sessions",
     "memory_path": "~/MyNotes/Memory",
     "plans_path": "~/MyNotes/Plans"
   }
   ```

- **entries_path**: Path to your daily notes directory
- **sessions_path**: Path to your session log directory (where Claude will store session logs)
- **memory_path**: Path to a directory for storing additional memory files for Claude
- **plans_path**: Path to your plans directory (used by automation hooks)

These can also be standard directories. They do not have to point to an Obsidian vault.

### How It Works

Slash commands dynamically load paths using bash + jq and are provided in the prompt:

```bash
# Get sessions path
cat ~/.claude/vault.json | jq -r '.sessions_path'

# Get memory path
cat ~/.claude/vault.json | jq -r '.memory_path'
```

## Automation Hooks

The `hooks/` directory contains automation scripts that enhance Claude Code workflows.
These hooks are triggered automatically by [Claude Code's hook system](https://docs.anthropic.com/en/docs/claude-code/hooks).

### Reddit Fetch Hook

#### `reddit-fetch.sh`

- **Triggered**: When `WebFetch` is called with Reddit URLs (reddit.com domains)
- **Purpose**: Provides comprehensive Reddit content retrieval via Reddit's public JSON API when standard web fetching is not available
- **Features**:
  - Seamless Reddit content access with enhanced functionality
  - Automatic crosspost detection and original content fetching
  - Community discussion capture (configurable comment count)
  - External link detection with actionable `Fetch("URL")` recommendations
  - Support for multiple post types (text, image, link, crosspost)
  - Comprehensive metadata display (scores, dates, authors, subreddits)
  - Subreddit browsing with configurable post count
- **Configuration**:
  - `MAX_COMMENTS=10` - Number of comments to display for individual posts
  - `MAX_POSTS=10` - Number of posts to display for subreddit listings
- **Usage**: Simply use `WebFetch("https://reddit.com/...")` and the hook provides enhanced content automatically

### Plan Management Hooks

Two hooks work together to integrate planning with the spec workflow:

#### `plan-extractor.sh`

- **Triggered**: When Claude uses the `exit_plan_mode` tool to present a plan
- **Purpose**: Creates plan.md in spec folder structure for spec generation
- **Features**:
  - Uses Claude Code SDK to generate kebab-case slug from title
  - Creates spec folder: `{spec_path}/{slug}/`
  - Saves plan with minimal frontmatter (session_id, status: draft)
  - Integrates with spec workflow for requirements generation
- **Configuration**: Uses `spec.json` hierarchy (project → global → default)
- **Output**: `{spec_path}/{slug}/plan.md`

#### `plan-cleanup.sh`

- **Triggered**: When user approves a plan after `exit_plan_mode`
- **Purpose**: Overwrites draft with approved version and triggers spec workflow
- **Features**:
  - Completely overwrites plan.md with approved content
  - Updates status to "approved" in frontmatter
  - Prompts for spec generation workflow
  - Ready for agent-based requirements generation
- **Output**: Updated plan.md with approved status

### Plan Mode and Spec Integration

The plan mode now integrates directly with the spec workflow:

1. **Automatic Spec Creation**: Approved plans trigger spec generation
2. **Agent-Based Workflow**: Specialized agents handle each phase
3. **Configurable Locations**: Use `spec.json` to customize spec folder
4. **Progressive Enhancement**: Plans → Requirements → Tasks → Implementation

See [docs/plan-mode-spec-integration.md](docs/plan-mode-spec-integration.md) for details.

#### Plan Workflow

1. Claude creates a plan using `exit_plan_mode` → `plan-extractor.sh` saves draft
2. User reviews, makes edits, and approves the plan → `plan-cleanup.sh`
3. Claude creates an approved copy and cleans up drafts
4. Result: Clean organization with approved plans archived

#### Configuration

Set `plans_path` in `vault.json`.

## Slash Commands

The `commands/` directory contains custom slash commands that extend Claude Code with specialized workflows.

Commands are organized by category:

### Git Commands (`/git/*`)

- **`/git/create-commit`**: Creates git commits with proper formatting
  - Enforces max 75 character limit
  - Prefixes commits with type (feat, fix, docs, etc.)
  - Analyzes changes to generate meaningful commit messages
- **`/git/create-pr`**: Creates comprehensive pull requests based on session changes
  - Generates PR title and body from commit history
  - Includes test plan and summary
  - Automatically pushes to remote if needed
- **`/git/update-pr`**: Updates existing PRs with recent commits
  - Fetches PR details and updates with new changes
  - Maintains PR description format

### Session Management (`/session/*`)

- **`/session/start`**: Initializes new sessions by loading relevant context from vault
  - Loads memory files from configured paths
  - Sets up session context for ongoing work
- **`/session/end`**: Closes sessions with proper documentation
  - Creates session logs in vault
  - Summarizes work completed
  - Archives session state

### Spec System (`/spec/*`)

A structured 4-phase approach for building features using EARS methodology:

- **`/spec/01-requirements`**: Requirements gathering using EARS (Easy Approach to Requirements Syntax)
  - Structured format: "When <trigger> the system shall <action>"
  - Creates formal requirements document
  - Supports external spec references
- **`/spec/02-design`**: Creates design documents with research capabilities
  - Integrates with Perplexity for research
  - Generates architecture and implementation designs
  - Creates detailed technical specifications
- **`/spec/03-implementation-plan`**: Creates actionable implementation task lists
  - Breaks down design into concrete tasks
  - Uses TodoWrite for task tracking
  - Prioritizes and sequences work
- **`/spec/04-task`**: Executes tasks from the implementation plan
  - Works through tasks systematically
  - Updates task status in real-time
  - Completes implementation based on plan

### Tools (`/tools/*`)

- **`/tools/mermaid-to-image`**: Converts Mermaid diagrams to images
  - Supports PNG, SVG, and PDF output formats
  - Uses mermaid-cli for rendering
  - Handles complex diagram types
- **`/tools/pbcopy`**: Copies relevant content from responses to clipboard
  - Extracts code blocks and specific content
  - Maintains formatting for pasting
- **`/tools/pbquote`**: Copies content formatted as block quotes
  - Formats for replying to messages
  - Preserves markdown structure
- **`/tools/site-to-md`**: Downloads and converts websites to markdown
  - Uses trafilatura for content extraction
  - Preserves article structure and metadata
  - Useful for research and documentation

### Standalone Commands

- **`/proofread`**: Professional proofreading and editing
  - Checks grammar, flow, and clarity
  - Preserves author's voice and style
  - Provides tracked changes and explanations
- **`/research`**: Comprehensive research with Perplexity integration
  - Structured research workflow
  - Source management and citation tracking
  - Detailed reporting with findings

### Key Features Across Commands

- **Tool Restrictions**: Each command has specific `allowed-tools` to limit access appropriately
- **Context Integration**: Commands use `!` syntax to execute and embed command output
- **Vault Integration**: Session commands integrate with Obsidian vault for persistence
- **Research Capabilities**: Multiple commands support web search via Perplexity MCP
- **EARS Methodology**: The spec system uses formal requirements syntax for clarity

All vault-integrated commands use the vault configuration system for portable path management and include dynamic context injection.

### System Info Utility (`bin/claude-sysinfo`)

A secure wrapper utility that provides system information without requiring broad bash permissions in slash commands. Commands can use `Bash(claude-sysinfo:*)`.

**Examples:**

- `claude-sysinfo session-context` - Full context for session commands
- `claude-sysinfo task-context` - Full context for task commands
- `claude-sysinfo date` - Current date (YYYY-MM-DD)
- `claude-sysinfo git-branch` - Current git branch
- `claude-sysinfo vault-tasks-path` - Tasks directory path

## Setup Instructions

### Adding Utilities to PATH

To use the utilities in `bin/` from anywhere in your system, add the directory to your PATH:

Add to your shell configuration file:

**For zsh:**

```bash
echo 'export PATH="$HOME/.claude/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**For bash:**

```bash
echo 'export PATH="$HOME/.claude/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Verify setup:**

```bash
which claude-sysinfo
# Should output: /Users/yourusername/.claude/bin/claude-sysinfo

claude-sysinfo date
# Should output current date in YYYY-MM-DD format
```
