# emdashcodes/.claude

This is a Claude Code configuration repository - like dotfiles, but for AI. This setup transforms Claude Code into a powerful, personalized development environment with custom commands, automated workflows, and persistent memory.

Share, fork, and customize this configuration to build your own AI-powered development toolkit based on your own workflow and preferences.

## Components

- **Custom Slash Commands**: Specialized tools for task management, research, calendar operations, and more
- **Hook Examples**: Automated tool interception and workflow enhancement
- **Smart Wrapper Script**: Auto-injects additional system prompt + optional menu mode for session selection
- **Utility Scripts**: Additional scripts to help with common workflows
- **Settings**: My personal settings for Claude Code

## 📁 Repository Structure

```
.claude/
├── README.md              # This file
├── CLAUDE.md              # My main Claude Code memory/instructions
├── EXAMPLE-PROMPT.md      # Auto-injected system prompt template for others to customize
├── settings.json          # Claude Code configuration
├── example.vault.json     # Example vault configuration (copy to vault.json)
├── vault.json             # Your vault paths configuration (gitignored)
├── commands/              # Custom slash commands with various utilities and workflows
├── hooks/                 # Automation hooks
├── bin/                   # Additional utility scripts (add to PATH)
└── local/
    └── claude             # Smart wrapper script
```

## Documentation

### Smart Wrapper Script (`local/claude`)

The wrapper enhances Claude Code with multiple additional features:

#### Auto System Prompt Injection

When you run interactive Claude commands (`claude`, `claude -c`, `claude -r`), the wrapper automatically appends your `PROMPT.md` content using `--append-system-prompt`, giving Claude your custom personality and instructions. Think of it as your personal AI configuration file. This is passed as part of the system prompt and is different from context loaded via CLAUDE.md. If an existing `--append-system-prompt` is provided, the two will be merged.

This does not run for scripts (`claude -p ...`).

#### Menu Mode (off by default)

- Set `CLAUDE_USE_MENU=1` to show interactive menu for plain `claude` commands
- Choose between: Start new / Resume previous / Continue last conversation
- Only affects bare `claude` - all other commands work normally

## Vault Configuration

The `vault.json` file configures paths to your knowledge vault, making Claude Code commands portable across different users and setups.

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
     "memory_path": "~/MyNotes/Memory"
   }
   ```

### How It Works

Commands dynamically load paths using bash + jq:

```bash
# Get tasks path
cat ~/.claude/vault.json | jq -r '.tasks_path'

# Get task template path  
cat ~/.claude/vault.json | jq -r '.task_template'
```

### Benefits

- **Portable**: Others can customize paths for their setup
- **Flexible**: Easy to reorganize vault structure 
- **Consistent**: All commands use same configuration source
- **Shareable**: Configurations can be shared while maintaining personal paths

Commands automatically adapt to your custom paths, making the configuration highly reusable across different vault structures and organizational preferences.
