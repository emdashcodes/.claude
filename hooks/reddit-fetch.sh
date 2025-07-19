#!/bin/bash
# Claude Hook: Reddit Fetch Interceptor
#
# PURPOSE:
#   Intercepts Fetch calls to Reddit URLs and provides alternative content retrieval
#   via Reddit's public JSON API endpoints, bypassing Claude Code's Reddit blocking.
#
# TRIGGERED BY:
#   Claude Code PreToolUse hook system when Fetch tool is called with Reddit URLs
#
# FUNCTIONALITY:
#   - Detects Reddit URLs in Fetch tool calls
#   - Transforms URLs to Reddit's JSON API endpoints
#   - Fetches content using curl with proper User-Agent
#   - Converts JSON response to readable markdown format
#   - Returns blocking decision with formatted content to Claude
#
# SUPPORTED URLS:
#   - Post URLs: reddit.com/r/sub/comments/id/title/ → reddit.com/r/sub/comments/id.json
#   - Subreddit URLs: reddit.com/r/sub/ → reddit.com/r/sub.json
#
# OUTPUT:
#   JSON response with decision:"block" and reason containing markdown content

# Configuration
MAX_COMMENTS=10
MAX_POSTS=10

# Read all input
JSON_DATA=$(cat)

# Extract URL from tool input
URL=$(echo "$JSON_DATA" | jq -r '.tool_input.url' 2>/dev/null)

# Check if URL extraction failed or is empty
if [ $? -ne 0 ] || [ -z "$URL" ] || [ "$URL" = "null" ]; then
    # Not a valid tool input, let normal flow continue
    exit 0
fi

# Check if this is a Reddit URL
if [[ ! "$URL" =~ reddit\.com ]]; then
    # Not a Reddit URL, let normal flow continue
    exit 0
fi

# Check if the tool failed with a domain blocking error (PostToolUse)
TOOL_RESPONSE=$(echo "$JSON_DATA" | jq -r '.tool_response' 2>/dev/null)
if [ "$TOOL_RESPONSE" != "null" ] && [ -n "$TOOL_RESPONSE" ]; then
    # Check if it's a domain blocking error
    if [[ "$TOOL_RESPONSE" =~ "not allowed to be fetched" ]] || [[ "$TOOL_RESPONSE" =~ "Domain.*is not allowed" ]]; then
        # This is the domain blocking error we want to handle
        echo "Reddit domain blocked - providing alternative content via hook" >&2
    else
        # Different error, let normal flow continue
        exit 0
    fi
fi

# Transform Reddit URL to JSON API endpoint
JSON_URL=""

# Handle post URLs: /r/subreddit/comments/postid/title/
if [[ "$URL" =~ reddit\.com/r/[^/]+/comments/([^/]+) ]]; then
    # Extract the post ID and construct JSON URL
    POST_ID="${BASH_REMATCH[1]}"
    JSON_URL=$(echo "$URL" | sed -E 's|(reddit\.com/r/[^/]+/comments/[^/]+).*|\1.json|')
# Handle subreddit URLs: /r/subreddit/ or /r/subreddit
elif [[ "$URL" =~ reddit\.com/r/[^/]+/?$ ]]; then
    # Add .json to subreddit URL
    JSON_URL=$(echo "$URL" | sed 's|/$||').json
else
    # Unsupported Reddit URL format, let normal flow continue
    exit 0
fi

# Fetch content from Reddit's JSON API
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
RESPONSE=$(curl -s -A "$USER_AGENT" -H "Accept: application/json" "$JSON_URL" 2>/dev/null)

# Check if curl succeeded
if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
    # Curl failed, return error to Claude
    cat << 'EOF'
{
  "decision": "block",
  "reason": "Failed to fetch Reddit content: Network error or invalid URL"
}
EOF
    exit 0
fi

# Check if response contains Reddit data
if ! echo "$RESPONSE" | jq -e '.[0].data.children' >/dev/null 2>&1 && ! echo "$RESPONSE" | jq -e '.data.children' >/dev/null 2>&1; then
    # Not valid Reddit JSON, return error
    cat << 'EOF'
{
  "decision": "block", 
  "reason": "Failed to fetch Reddit content: Invalid response format or rate limited"
}
EOF
    exit 0
fi

# Process Reddit JSON and convert to markdown
MARKDOWN_CONTENT=""
FETCH_RECOMMENDATIONS=""

# Check if this is a post response (array with post and comments)
if echo "$RESPONSE" | jq -e '.[0].data.children[0].data.title' >/dev/null 2>&1; then
    # This is a post with comments
    POST_DATA=$(echo "$RESPONSE" | jq -r '.[0].data.children[0].data')
    
    TITLE=$(echo "$POST_DATA" | jq -r '.title')
    SELFTEXT=$(echo "$POST_DATA" | jq -r '.selftext // ""')
    AUTHOR=$(echo "$POST_DATA" | jq -r '.author')
    SUBREDDIT=$(echo "$POST_DATA" | jq -r '.subreddit')
    SCORE=$(echo "$POST_DATA" | jq -r '.score')
    NUM_COMMENTS=$(echo "$POST_DATA" | jq -r '.num_comments')
    CREATED_UTC=$(echo "$POST_DATA" | jq -r '.created_utc')
    PERMALINK=$(echo "$POST_DATA" | jq -r '.permalink')
    POST_URL=$(echo "$POST_DATA" | jq -r '.url // ""')
    IS_SELF=$(echo "$POST_DATA" | jq -r '.is_self')
    
    # Convert Unix timestamp to readable date (handle floating point)
    if command -v date >/dev/null 2>&1 && [ -n "$CREATED_UTC" ] && [ "$CREATED_UTC" != "null" ]; then
        # Convert floating point to integer for date command
        CREATED_TIMESTAMP=$(echo "$CREATED_UTC" | cut -d. -f1)
        CREATED_DATE=$(date -r "$CREATED_TIMESTAMP" "+%Y-%m-%d %H:%M %Z" 2>/dev/null || echo "Unknown date")
    else
        CREATED_DATE="Unknown date"
    fi
    
    MARKDOWN_CONTENT="# $TITLE

**Subreddit:** r/$SUBREDDIT  
**Author:** u/$AUTHOR  
**Score:** $SCORE  
**Comments:** $NUM_COMMENTS  
**Posted:** $CREATED_DATE  
**URL:** https://reddit.com$PERMALINK

"
    
    # Handle different post types
    if [ "$IS_SELF" = "true" ]; then
        # This is a self/text post
        if [ -n "$SELFTEXT" ] && [ "$SELFTEXT" != "" ]; then
            MARKDOWN_CONTENT+="## Post Content

$SELFTEXT

"
        fi
    elif [[ "$POST_URL" =~ reddit\.com ]] || [[ "$POST_URL" =~ ^/r/ ]]; then
        # This is a crosspost to another Reddit post
        MARKDOWN_CONTENT+="## Crosspost Notice

This post links to another Reddit post. Let me fetch that content too...

"
        
        # Transform the crosspost URL to JSON format
        CROSSPOST_JSON_URL=""
        
        # Handle relative URLs (starting with /r/)
        if [[ "$POST_URL" =~ ^/r/[^/]+/comments/([^/]+) ]]; then
            CROSSPOST_JSON_URL="https://www.reddit.com$POST_URL.json"
        # Handle full reddit.com URLs
        elif [[ "$POST_URL" =~ reddit\.com/r/[^/]+/comments/([^/]+) ]]; then
            CROSSPOST_JSON_URL=$(echo "$POST_URL" | sed -E 's|(reddit\.com/r/[^/]+/comments/[^/]+).*|\1.json|')
        fi
        
        # Fetch crosspost content if we have a valid URL
        if [ -n "$CROSSPOST_JSON_URL" ]; then
            CROSSPOST_RESPONSE=$(curl -s -A "$USER_AGENT" -H "Accept: application/json" "$CROSSPOST_JSON_URL" 2>/dev/null)
            
            if [ $? -eq 0 ] && echo "$CROSSPOST_RESPONSE" | jq -e '.[0].data.children[0].data.title' >/dev/null 2>&1; then
                CROSSPOST_DATA=$(echo "$CROSSPOST_RESPONSE" | jq -r '.[0].data.children[0].data')
                CROSSPOST_TITLE=$(echo "$CROSSPOST_DATA" | jq -r '.title')
                CROSSPOST_SELFTEXT=$(echo "$CROSSPOST_DATA" | jq -r '.selftext // ""')
                CROSSPOST_AUTHOR=$(echo "$CROSSPOST_DATA" | jq -r '.author')
                CROSSPOST_SUBREDDIT=$(echo "$CROSSPOST_DATA" | jq -r '.subreddit')
                CROSSPOST_SCORE=$(echo "$CROSSPOST_DATA" | jq -r '.score')
                
                MARKDOWN_CONTENT+="### Original Post: $CROSSPOST_TITLE

**Original Subreddit:** r/$CROSSPOST_SUBREDDIT  
**Original Author:** u/$CROSSPOST_AUTHOR  
**Original Score:** $CROSSPOST_SCORE  

"
                
                if [ -n "$CROSSPOST_SELFTEXT" ] && [ "$CROSSPOST_SELFTEXT" != "" ]; then
                    MARKDOWN_CONTENT+="**Original Content:**

$CROSSPOST_SELFTEXT

"
                fi
            else
                MARKDOWN_CONTENT+="*Could not fetch crosspost content from: $POST_URL*

"
            fi
        fi
    else
        # This is a link to external content
        if [ -n "$POST_URL" ] && [ "$POST_URL" != "" ] && [ "$POST_URL" != "null" ]; then
            MARKDOWN_CONTENT+="## External Link

This post links to external content: **$POST_URL**

"
            # Add to fetch recommendations
            FETCH_RECOMMENDATIONS+="- \`Fetch(\"$POST_URL\")\` - Retrieve the linked content
"
        fi
    fi
    
    # Add top comments if available
    if echo "$RESPONSE" | jq -e '.[1].data.children[0]' >/dev/null 2>&1; then
        MARKDOWN_CONTENT+="## Top Comments

"
        # Extract first few comments (configurable amount)
        COMMENTS=$(echo "$RESPONSE" | jq -r ".[1].data.children[0:$MAX_COMMENTS][] | select(.data.body and .data.body != null and .data.body != \"\") | \"**\" + .data.author + \"** (Score: \" + (.data.score | tostring) + \"):\n\" + .data.body + \"\n---\n\"" 2>/dev/null)
        
        if [ -n "$COMMENTS" ]; then
            MARKDOWN_CONTENT+="$COMMENTS"
        else
            MARKDOWN_CONTENT+="*No readable comments found or comments may be collapsed.*

"
        fi
    fi

# Check if this is a subreddit listing
elif echo "$RESPONSE" | jq -e '.data.children[0].data.title' >/dev/null 2>&1; then
    # This is a subreddit listing
    SUBREDDIT_NAME=$(echo "$RESPONSE" | jq -r '.data.children[0].data.subreddit')
    
    MARKDOWN_CONTENT="# r/$SUBREDDIT_NAME

## Recent Posts

"
    
    # Extract top posts (configurable amount)
    echo "$RESPONSE" | jq -r ".data.children[0:$MAX_POSTS][] | select(.data.title != null) | \"### \" + .data.title + \"\n\n**Author:** u/\" + .data.author + \" | **Score:** \" + (.data.score | tostring) + \" | **Comments:** \" + (.data.num_comments | tostring) + \"\n\n\" + (.data.selftext // \"\") + \"\n\n---\n\"" > /tmp/reddit_posts.md
    
    MARKDOWN_CONTENT+=$(cat /tmp/reddit_posts.md)
    rm -f /tmp/reddit_posts.md
else
    # Unknown format
    MARKDOWN_CONTENT="# Reddit Content

Unable to parse Reddit response format. Raw JSON structure detected but content could not be extracted into readable format."
fi

# Add fetch recommendations at the bottom if any exist
if [ -n "$FETCH_RECOMMENDATIONS" ]; then
    MARKDOWN_CONTENT+="

---

## 💡 Recommended Actions

$FETCH_RECOMMENDATIONS"
fi

# Escape the markdown content for JSON (remove outer quotes from jq -Rs output)
ESCAPED_CONTENT=$(echo "$MARKDOWN_CONTENT" | jq -Rs . | sed 's/^"//; s/"$//')

# Return blocking decision with markdown content (for PostToolUse)
cat << EOF
{
  "decision": "block",
  "reason": "Reddit content retrieved via alternative method:\\n\\n$ESCAPED_CONTENT"
}
EOF