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

## Obsidian Integration

The `vault.json` file configures paths to your knowledge vault. These paths are provided to specific Claude Code commands to load relevant files:

- `commands/task-load.md`: Load task context
- `commands/task-new.md`: Create new task
- `commands/task-archive.md`: Archive cancelled/obsolete tasks
- `commands/task-complete.md`: Move completed tasks
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
     "tasks_path": "~/MyNotes/Projects",
     "entries_path": "~/MyNotes/Daily",
     "sessions_path": "~/MyNotes/Sessions",
     "task_template": "~/MyNotes/Templates/Task.md",
     "memory_path": "~/MyNotes/Memory",
     "plans_path": "~/MyNotes/Plans"
   }
   ```

- **tasks_path**: Path to your tasks directory
- **entries_path**: Path to your daily notes directory
- **sessions_path**: Path to your session log directory (where Claude will store session logs)
- **task_template**: Path to a template file for tasks
- **memory_path**: Path to a directory for storing additional memory files for Claude
- **plans_path**: Path to your plans directory (used by automation hooks)

These can also be standard directories. They do not have to point to an Obsidian vault.

### How It Works

Slash commands dynamically load paths using bash + jq and are provided in the prompt:

```bash
# Get tasks path
cat ~/.claude/vault.json | jq -r '.tasks_path'

# Get task template path
cat ~/.claude/vault.json | jq -r '.task_template'
```

## Automation Hooks

The `hooks/` directory contains automation scripts that enhance Claude Code workflows.
These hooks are triggered automatically by [Claude Code's hook system](https://docs.anthropic.com/en/docs/claude-code/hooks).

### Plan Management Hooks

Two hooks work together to enhance Claude's planning workflow:

#### `plan-extractor.sh`

- **Triggered**: When Claude uses the `exit_plan_mode` tool to present a plan
- **Purpose**: Automatically captures and saves plan content as draft files
- **Features**:
  - Extracts plan content from Claude's hook JSON data
  - Generates intelligent filenames based on plan title + session ID
  - Adds comprehensive metadata (session, tmux, directory, timestamp)
  - Saves to configurable plans directory with "draft" status
- **Output**: `"Plan Title (12345678).md"` in configured plans_path

#### `plan-cleanup.sh`

- **Triggered**: When user approves a plan after `exit_plan_mode`
- **Purpose**: Creates approved plan copy and cleans up draft files
- **Features**:
  - Creates approved version in `/Accepted` subdirectory
  - Updates plan status to "approved" in frontmatter
  - Removes all draft plan files for the session to prevent clutter
  - Maintains organized plan archive structure
- **Output**: Approved plans in `[plans_path]/Accepted/`

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

### Task Management

- **`/task-new`**: Create new task with template and metadata
- **`/task-load`**: Search and load existing task context
- **`/task-complete`**: Mark task as completed and move to archive
- **`/task-archive`**: Archive cancelled or obsolete tasks

### Session Management

- **`/session-start`**: Begin new session with vault context
- **`/session-start-task`**: Start session focused on specific task
- **`/session-end`**: Close session with proper documentation

### Git & Development

- **`/create-commit`**: Create git commit with context analysis
- **`/create-pr`**: Create GitHub pull request with comprehensive details
- **`/update-pr`**: Update existing PR with recent changes

### Research & Content

- **`/research`**: Structured research workflow with source management
- **`/site-to-md`**: Convert websites to markdown for analysis
- **`/proofread`**: Professional proofreading and editing workflow

### Utilities

- **`/pbcopy`**: Copy content to clipboard with formatting
- **`/pbquote`**: Quote and copy formatted text blocks

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
