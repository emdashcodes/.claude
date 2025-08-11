#!/bin/bash
# Claude Hook: GitHub Fetch Interceptor
#
# PURPOSE:
#   Intercepts Fetch calls to GitHub URLs and retrieves content using gh CLI
#   instead, ensuring compatibility with both GitHub.com and GitHub Enterprise.
#
# TRIGGERED BY:
#   Claude Code PreToolUse hook system when WebFetch tool is called with GitHub URLs
#
# FUNCTIONALITY:
#   - Detects GitHub URLs (github.com and configured enterprise domains)
#   - Transforms URLs to appropriate gh CLI commands with --repo flag
#   - Returns raw gh output with suggestion to use gh directly
#   - Supports issues, PRs, repos, files, commits, releases, actions, user/org profiles
#   - Provides rich output with multiple commands for comprehensive info
#
# CONFIGURATION:
#   Enterprise domains and proxy settings configured in ~/.claude/github-config.json
#
# OUTPUT:
#   JSON response with decision:"block" and reason containing gh output
#
# ============================================================================
# IMPORTANT NOTES FOR FUTURE MAINTAINERS:
# ============================================================================
#
# 1. COMMAND SEPARATION:
#    - DO NOT combine gh commands with && or || operators in a single array element
#    - Each gh command MUST be its own array element for proxy to work correctly
#    - BAD:  GH_COMMANDS+=("echo 'title' && gh api repos/...")
#    - GOOD: GH_COMMANDS+=("echo 'title'")
#           GH_COMMANDS+=("gh api repos/...")
#
# 2. ENTERPRISE API PATHS:
#    - Enterprise GitHub uses different API paths than GitHub.com
#    - Enterprise: https://domain.com/api/v3/repos/...
#    - GitHub.com: repos/... (relative path)
#    - Always check $DOMAIN and use full URLs for enterprise
#
# 3. PROXY HANDLING:
#    - Proxy settings are applied by run_gh_command() function
#    - Proxy ONLY works when gh commands are separate array elements
#    - Enterprise domains often require SOCKS5 proxies
#
# 4. REPO FLAG FORMAT:
#    - Enterprise needs full URL: --repo https://domain.com/owner/repo
#    - GitHub.com can use shorthand: --repo owner/repo
#    - Use get_repo_flag() function to handle this automatically
#
# 5. QUOTING API PATHS:
#    - API paths with query parameters MUST be quoted
#    - Use single quotes to prevent shell expansion: 'repos/owner/repo?ref=main'
#
# 6. ERROR HANDLING:
#    - Don't use || or 2>/dev/null in commands - let errors propagate
#    - The main execution loop handles errors appropriately
#
# 7. TESTING:
#    - Always test changes with BOTH GitHub.com and enterprise URLs
#    - Test with: echo '{"tool_input": {"url": "..."}}' | ./github-fetch.sh
#
# ============================================================================

# Read all input
JSON_DATA=$(cat)

# Extract URL from tool input
URL=$(echo "$JSON_DATA" | jq -r '.tool_input.url' 2>/dev/null)

# Check if URL extraction failed or is empty
if [ $? -ne 0 ] || [ -z "$URL" ] || [ "$URL" = "null" ]; then
    # Not a valid tool input, let normal flow continue
    exit 0
fi

# Load enterprise domains from config if it exists
CONFIG_FILE="$HOME/.claude/github-config.json"
ENTERPRISE_DOMAINS=""
if [ -f "$CONFIG_FILE" ]; then
    ENTERPRISE_DOMAINS=$(jq -r '.enterprise_domains[]' "$CONFIG_FILE" 2>/dev/null | tr '\n' '|' | sed 's/|$//')
fi

# Build regex pattern for GitHub domains
GITHUB_PATTERN="github\.com"
if [ -n "$ENTERPRISE_DOMAINS" ]; then
    # Escape dots in domain names for regex
    ESCAPED_DOMAINS=$(echo "$ENTERPRISE_DOMAINS" | sed 's/\./\\./g')
    GITHUB_PATTERN="(github\.com|$ESCAPED_DOMAINS)"
fi

# Check if this is a GitHub URL
if ! echo "$URL" | grep -qE "$GITHUB_PATTERN"; then
    # Not a GitHub URL, let normal flow continue
    exit 0
fi

# Parse the URL to extract components
# Remove protocol and trailing slash
CLEAN_URL=$(echo "$URL" | sed -E 's|^https?://||; s|/$||')

# Extract domain and path (remove query parameters)
DOMAIN=$(echo "$CLEAN_URL" | cut -d'/' -f1)
PATH_PART=$(echo "$CLEAN_URL" | cut -d'/' -f2- | cut -d'?' -f1)

# Initialize variables
GH_COMMANDS=()
REPO=""

# Load proxy settings from config
get_proxy_for_domain() {
    local domain="$1"
    if [ -f "$CONFIG_FILE" ]; then
        local http_proxy=$(jq -r ".proxy_settings.\"$domain\".http_proxy // empty" "$CONFIG_FILE" 2>/dev/null)
        local https_proxy=$(jq -r ".proxy_settings.\"$domain\".https_proxy // empty" "$CONFIG_FILE" 2>/dev/null)
        if [ -n "$http_proxy" ] && [ -n "$https_proxy" ]; then
            echo "HTTP_PROXY=$http_proxy HTTPS_PROXY=$https_proxy"
        fi
    fi
}

# Function to run command with proxy if needed
run_gh_command() {
    local cmd="$1"
    local proxy_env=$(get_proxy_for_domain "$DOMAIN")
    if [ -n "$proxy_env" ]; then
        # Use proxy settings from config
        # Running in bash context, so we need to set proxy env vars
        eval "$proxy_env $cmd" 2>&1
    else
        eval "$cmd" 2>&1
    fi
}

# Determine if we need full URL for --repo flag (for enterprise GitHub)
get_repo_flag() {
    local repo="$1"
    if [[ "$DOMAIN" != "github.com" ]]; then
        # Enterprise GitHub needs full URL
        echo "https://$DOMAIN/$repo"
    else
        # github.com can use shorthand
        echo "$repo"
    fi
}

# Parse GitHub URL patterns and build commands
if [[ "$PATH_PART" =~ ^([^/]+)/([^/]+)/?$ ]]; then
    # Repository URL: github.com/owner/repo
    OWNER=$(echo "$PATH_PART" | cut -d'/' -f1)
    REPO_NAME=$(echo "$PATH_PART" | cut -d'/' -f2)
    REPO="$OWNER/$REPO_NAME"
    REPO_FLAG=$(get_repo_flag "$REPO")
    
    GH_COMMANDS+=("gh repo view $REPO_FLAG")
    
elif [[ "$PATH_PART" =~ ^([^/]+)/([^/]+)/issues/([0-9]+) ]]; then
    # Issue URL: github.com/owner/repo/issues/123
    OWNER=$(echo "$PATH_PART" | cut -d'/' -f1)
    REPO_NAME=$(echo "$PATH_PART" | cut -d'/' -f2)
    ISSUE_NUM=$(echo "$PATH_PART" | sed -E 's|.*/issues/([0-9]+).*|\1|')
    REPO="$OWNER/$REPO_NAME"
    REPO_FLAG=$(get_repo_flag "$REPO")
    
    # Get issue with comments
    GH_COMMANDS+=("gh issue view $ISSUE_NUM --repo $REPO_FLAG --comments")
    
elif [[ "$PATH_PART" =~ ^([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
    # Pull Request URL: github.com/owner/repo/pull/123
    OWNER=$(echo "$PATH_PART" | cut -d'/' -f1)
    REPO_NAME=$(echo "$PATH_PART" | cut -d'/' -f2)
    PR_NUM=$(echo "$PATH_PART" | sed -E 's|.*/pull/([0-9]+).*|\1|')
    REPO="$OWNER/$REPO_NAME"
    REPO_FLAG=$(get_repo_flag "$REPO")
    
    # Get multiple views of the PR for comprehensive info
    GH_COMMANDS+=("echo '=== PR DETAILS ==='")
    GH_COMMANDS+=("gh pr view $PR_NUM --repo $REPO_FLAG")
    
    # Get comments - use JSON for enterprise to avoid timeouts
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo '=== PR COMMENTS ==='")
    if [[ "$DOMAIN" != "github.com" ]]; then
        # For enterprise, use JSON output to avoid timeouts
        GH_COMMANDS+=("gh pr view $PR_NUM --repo $REPO_FLAG --json comments --jq '.comments | if length > 0 then .[] | \"Comment by \\(.author.login) at \\(.createdAt):\\n\\(.body)\\n\" else \"No comments on this PR\" end'")
    else
        # For github.com, use the standard comments flag
        GH_COMMANDS+=("gh pr view $PR_NUM --repo $REPO_FLAG --comments")
    fi
    
    # Show list of changed files (useful when diff is truncated)
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo '=== FILES CHANGED ==='")
    GH_COMMANDS+=("gh pr view $PR_NUM --repo $REPO_FLAG --json files --jq '.files[] | \"\\(.path) (+\\(.additions) -\\(.deletions))\"'")
    
    # Add separator and truncated diff (800 chars max)
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo '=== PR DIFF (truncated to 800 chars) ==='")
    GH_COMMANDS+=("gh pr diff $PR_NUM --repo $REPO_FLAG | head -c 800")
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo 'For full diff, run: gh pr diff $PR_NUM --repo $REPO_FLAG'")
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo '=== PR CHECKS ==='")
    GH_COMMANDS+=("gh pr checks $PR_NUM --repo $REPO_FLAG")
    
elif [[ "$PATH_PART" =~ ^([^/]+)/([^/]+)/blob/([^/]+)/(.+) ]]; then
    # File URL: github.com/owner/repo/blob/branch/path/to/file
    OWNER=$(echo "$PATH_PART" | cut -d'/' -f1)
    REPO_NAME=$(echo "$PATH_PART" | cut -d'/' -f2)
    BRANCH=$(echo "$PATH_PART" | cut -d'/' -f4)
    FILE_PATH=$(echo "$PATH_PART" | cut -d'/' -f5-)
    REPO="$OWNER/$REPO_NAME"
    
    # Get file contents
    GH_COMMANDS+=("echo '=== FILE: $FILE_PATH ==='")
    if [[ "$DOMAIN" != "github.com" ]]; then
        # For enterprise, use full API URL
        GH_COMMANDS+=("gh api 'https://$DOMAIN/api/v3/repos/$REPO/contents/$FILE_PATH?ref=$BRANCH' -q '.content' | base64 -d")
    else
        # For github.com, use the standard API path
        GH_COMMANDS+=("gh api 'repos/$REPO/contents/$FILE_PATH?ref=$BRANCH' -q '.content' | base64 -d")
    fi
    
elif [[ "$PATH_PART" =~ ^([^/]+)/([^/]+)/tree/([^/]+) ]]; then
    # Tree/Directory URL: github.com/owner/repo/tree/branch/path
    OWNER=$(echo "$PATH_PART" | cut -d'/' -f1)
    REPO_NAME=$(echo "$PATH_PART" | cut -d'/' -f2)
    BRANCH=$(echo "$PATH_PART" | cut -d'/' -f4)
    TREE_PATH=$(echo "$PATH_PART" | cut -d'/' -f5-)
    REPO="$OWNER/$REPO_NAME"
    
    if [ -z "$TREE_PATH" ]; then
        # Root of branch
        if [[ "$DOMAIN" != "github.com" ]]; then
            GH_COMMANDS+=("gh api \"https://$DOMAIN/api/v3/repos/$REPO/contents?ref=$BRANCH\"")
        else
            GH_COMMANDS+=("gh api repos/$REPO/contents?ref=$BRANCH")
        fi
    else
        # Specific directory
        if [[ "$DOMAIN" != "github.com" ]]; then
            GH_COMMANDS+=("gh api \"https://$DOMAIN/api/v3/repos/$REPO/contents/$TREE_PATH?ref=$BRANCH\"")
        else
            GH_COMMANDS+=("gh api repos/$REPO/contents/$TREE_PATH?ref=$BRANCH")
        fi
    fi
    
elif [[ "$PATH_PART" =~ ^([^/]+)/([^/]+)/commit/([a-f0-9]+) ]]; then
    # Commit URL: github.com/owner/repo/commit/sha
    OWNER=$(echo "$PATH_PART" | cut -d'/' -f1)
    REPO_NAME=$(echo "$PATH_PART" | cut -d'/' -f2)
    COMMIT_SHA=$(echo "$PATH_PART" | sed -E 's|.*/commit/([a-f0-9]+).*|\1|')
    REPO="$OWNER/$REPO_NAME"
    
    # Get commit details and diff
    GH_COMMANDS+=("echo '=== COMMIT INFO ==='")
    if [[ "$DOMAIN" != "github.com" ]]; then
        # For enterprise, use full API URL
        GH_COMMANDS+=("gh api \"https://$DOMAIN/api/v3/repos/$REPO/commits/$COMMIT_SHA\" --jq '{message: .commit.message, author: .commit.author.name, date: .commit.author.date, stats: .stats}'")
    else
        # For github.com, use standard API path
        GH_COMMANDS+=("gh api repos/$REPO/commits/$COMMIT_SHA --jq '{message: .commit.message, author: .commit.author.name, date: .commit.author.date, stats: .stats}'")
    fi
    
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo '=== COMMIT FILES ==='")
    if [[ "$DOMAIN" != "github.com" ]]; then
        GH_COMMANDS+=("gh api \"https://$DOMAIN/api/v3/repos/$REPO/commits/$COMMIT_SHA\" --jq '.files[] | \"\\(.filename) [\\(.status)] +\\(.additions) -\\(.deletions)\"'")
    else
        GH_COMMANDS+=("gh api repos/$REPO/commits/$COMMIT_SHA --jq '.files[] | \"\\(.filename) [\\(.status)] +\\(.additions) -\\(.deletions)\"'")
    fi
    
elif [[ "$PATH_PART" =~ ^([^/]+)/([^/]+)/releases ]]; then
    # Releases URL: github.com/owner/repo/releases
    OWNER=$(echo "$PATH_PART" | cut -d'/' -f1)
    REPO_NAME=$(echo "$PATH_PART" | cut -d'/' -f2)
    REPO="$OWNER/$REPO_NAME"
    REPO_FLAG=$(get_repo_flag "$REPO")
    
    # Get releases and latest release details
    GH_COMMANDS+=("echo '=== RELEASES (first 10) ==='")
    GH_COMMANDS+=("gh release list --repo $REPO_FLAG --limit 10")
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo '=== LATEST RELEASE ==='")
    GH_COMMANDS+=("gh release view --repo $REPO_FLAG")
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo 'For all releases, run: gh release list --repo $REPO_FLAG'")
    
elif [[ "$PATH_PART" =~ ^([^/]+)/([^/]+)/actions ]]; then
    # Actions/Workflows URL: github.com/owner/repo/actions
    OWNER=$(echo "$PATH_PART" | cut -d'/' -f1)
    REPO_NAME=$(echo "$PATH_PART" | cut -d'/' -f2)
    REPO="$OWNER/$REPO_NAME"
    REPO_FLAG=$(get_repo_flag "$REPO")
    
    # Get workflows and recent runs
    GH_COMMANDS+=("echo '=== WORKFLOWS ==='")
    GH_COMMANDS+=("gh workflow list --repo $REPO_FLAG")
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo '=== RECENT RUNS (first 5) ==='")
    GH_COMMANDS+=("gh run list --repo $REPO_FLAG --limit 5")
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo 'For more runs, run: gh run list --repo $REPO_FLAG --limit 20'")
    
elif [[ "$PATH_PART" =~ ^([^/]+)/?$ ]]; then
    # User/Organization URL: github.com/username
    USER_OR_ORG=$(echo "$PATH_PART" | cut -d'/' -f1)
    
    # Try to get user/org info and their public repos
    GH_COMMANDS+=("echo '=== PROFILE ==='")
    GH_COMMANDS+=("gh api users/$USER_OR_ORG --jq '{name, login, bio, company, location, blog, public_repos, followers, following, created_at}'")
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo '=== RECENT PUBLIC REPOS (first 10) ==='")
    GH_COMMANDS+=("gh api users/$USER_OR_ORG/repos?per_page=10 --jq '.[] | \"\\(.full_name) - \\(.description // \"No description\") [⭐ \\(.stargazers_count)]\"'")
    GH_COMMANDS+=("echo ''")
    GH_COMMANDS+=("echo 'For more repos, run: gh api users/$USER_OR_ORG/repos?per_page=100 --jq .[]'")
    
else
    # Unsupported GitHub URL pattern, let normal flow continue
    exit 0
fi

# Execute all gh commands
if [ ${#GH_COMMANDS[@]} -gt 0 ]; then
    OUTPUT=""
    ALL_SUCCESS=true
    
    # Run each command and collect output
    for cmd in "${GH_COMMANDS[@]}"; do
        CMD_OUTPUT=$(run_gh_command "$cmd")
        CMD_EXIT=$?
        
        if [ $CMD_EXIT -ne 0 ]; then
            # Only fail completely if the first/main command fails
            if [ -z "$OUTPUT" ]; then
                ALL_SUCCESS=false
                OUTPUT="Error: $CMD_OUTPUT"
                break
            fi
            # For subsequent commands, just skip them if they fail
        else
            if [ -n "$OUTPUT" ]; then
                OUTPUT="$OUTPUT

$CMD_OUTPUT"
            else
                OUTPUT="$CMD_OUTPUT"
            fi
        fi
    done
    
    if [ "$ALL_SUCCESS" = false ]; then
        # Main command failed
        ESCAPED_OUTPUT=$(echo "$OUTPUT" | jq -Rs . | sed 's/^"//; s/"$//')
        # Extract the first actual gh command (skip echo commands)
        FIRST_CMD=""
        for cmd in "${GH_COMMANDS[@]}"; do
            if [[ "$cmd" == gh* ]]; then
                FIRST_CMD="$cmd"
                break
            fi
        done
        cat << EOF
{
  "decision": "block",
  "reason": "Failed to fetch GitHub content using gh CLI:\\n\\n$ESCAPED_OUTPUT\\n\\nTried command: $FIRST_CMD"
}
EOF
    else
        # Success - return the output with suggestions
        ESCAPED_OUTPUT=$(echo "$OUTPUT" | jq -Rs . | sed 's/^"//; s/"$//')
        
        # Build commands info from actual gh commands used
        HINT="Data fetched via:"
        for cmd in "${GH_COMMANDS[@]}"; do
            # Only show actual gh commands, not echo statements
            if [[ "$cmd" == gh* ]]; then
                # Clean up complex commands for display
                DISPLAY_CMD=$(echo "$cmd" | sed 's/ | head -c [0-9]*//' | sed 's/ 2>\/dev\/null.*//' | sed 's/ --jq .*//')
                # Don't duplicate the same command
                if [[ "$HINT" != *"$DISPLAY_CMD"* ]]; then
                    HINT="$HINT
  - \`$DISPLAY_CMD\`"
                fi
            fi
        done
        
        ESCAPED_HINT=$(echo "$HINT" | jq -Rs . | sed 's/^"//; s/"$//')
        
        cat << EOF
{
  "decision": "block",
  "reason": "GitHub content retrieved via gh CLI:\\n\\n$ESCAPED_OUTPUT\\n\\n$ESCAPED_HINT"
}
EOF
    fi
    
    exit 0
fi

# If we get here, something went wrong - let normal flow continue
exit 0