#!/bin/bash

# Claude Code status line
input=$(cat)
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')

# Colors
cyan="\033[36m"
yellow="\033[33m"
green="\033[32m"
blue="\033[34m"
purple="\033[35m"
gray="\033[90m"
orange="\033[38;5;208m"
red="\033[31m"
reset="\033[0m"

# Git info for current directory
git_branch=$(cd "$current_dir" 2>/dev/null && git branch --show-current 2>/dev/null)
git_status=$(cd "$current_dir" 2>/dev/null && git status --porcelain 2>/dev/null)

# Git info for project directory (if different)
if [ "$current_dir" != "$project_dir" ] && [ -n "$project_dir" ] && [ "$project_dir" != "null" ]; then
    project_git_branch=$(cd "$project_dir" 2>/dev/null && git branch --show-current 2>/dev/null)
    project_git_status=$(cd "$project_dir" 2>/dev/null && git status --porcelain 2>/dev/null)
fi

# Tmux session
tmux_session=$(if [ -n "$TMUX" ]; then tmux display-message -p '#S'; fi)

# Directory display - show both project and current if different
current_display=$(echo "$current_dir" | sed "s|^$HOME|~|")
project_display=$(echo "$project_dir" | sed "s|^$HOME|~|")

# Determine what to display
if [ "$current_dir" = "$project_dir" ] || [ -z "$project_dir" ] || [ "$project_dir" = "null" ]; then
    dir_display="$current_display"
else
    # Show both when different (project → cwd)
    dir_display=$(printf "%s %b→ [cwd]%b %s" "$project_display" "$gray" "$reset" "$current_display")
fi


# Start building status line
# Tmux session first
if [ -n "$tmux_session" ]; then
    printf "${gray}↣ ${green}%s${reset} ${gray}•${reset} " "$tmux_session"
fi

# Directory and git info
if [ "$current_dir" = "$project_dir" ] || [ -z "$project_dir" ] || [ "$project_dir" = "null" ]; then
    # Single directory - show with its git info
    printf "${cyan}%s${reset}" "$dir_display"
    if [ -n "$git_branch" ]; then
        if [ -n "$git_status" ]; then
            printf " ${gray}(${yellow}%s${orange}*${gray})${reset}" "$git_branch"
        else
            printf " ${gray}(${yellow}%s${gray})${reset}" "$git_branch"
        fi
    fi
else
    # Two directories - show each with their own git info
    printf "${cyan}%s${reset}" "$project_display"
    if [ -n "$project_git_branch" ]; then
        if [ -n "$project_git_status" ]; then
            printf " ${gray}(${yellow}%s${orange}*${gray})${reset}" "$project_git_branch"
        else
            printf " ${gray}(${yellow}%s${gray})${reset}" "$project_git_branch"
        fi
    fi

    printf " ${gray}→ [cwd]${reset} ${cyan}%s${reset}" "$current_display"
    if [ -n "$git_branch" ]; then
        if [ -n "$git_status" ]; then
            printf " ${gray}(${yellow}%s${orange}*${gray})${reset}" "$git_branch"
        else
            printf " ${gray}(${yellow}%s${gray})${reset}" "$git_branch"
        fi
    fi
fi

# Model name
printf " ${gray}• ${purple}%s${reset}" "$model_name"

printf "\n"