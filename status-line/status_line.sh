#!/bin/bash
# Claude Code Status Line
# Displays: Model | Branch | [Context Bar] % (tokens) \n Bar X% used · resets in Yhr Zm

input=$(cat)

# Extract fields
model=$(echo "$input" | jq -r '.model.display_name' | sed 's/Claude //' | sed 's/ Sonnet/S/' | sed 's/ Opus/O/' | sed 's/ Haiku/H/')
usage=$(echo "$input" | jq '.context_window.current_usage')
vim=$(echo "$input" | jq -r '.vim.mode // empty')

# Build status string
status="$model"

# Add effort level (from user-level settings.json; effort is a global setting)
effort=$(jq -r '.effortLevel // empty' "$HOME/.claude/settings.json" 2>/dev/null)
[ -n "$effort" ] && status="$status \033[38;5;80m($effort)\033[0m"

# Add git branch (from cwd)
_cwd=$(echo "$input" | jq -r '.cwd // empty')
if [ -n "$_cwd" ]; then
    branch=$(git -C "$_cwd" branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
            status="$status | $branch"
        else
            status="$status | \033[36m$branch\033[0m"
        fi
    fi
fi

# Add vim mode
[ "$vim" = "NORMAL" ] && status="$status [N]"
[ "$vim" = "INSERT" ] && status="$status [I]"

# Add context usage (no progress bar, just numbers)
if [ "$usage" != "null" ]; then
    input_t=$(echo "$usage" | jq '.input_tokens // 0')
    cache_c=$(echo "$usage" | jq '.cache_creation_input_tokens // 0')
    cache_r=$(echo "$usage" | jq '.cache_read_input_tokens // 0')
    current=$((input_t + cache_c + cache_r))
    size=$(echo "$input" | jq '.context_window.context_window_size')

    # If auto-compact window is configured and smaller than the raw model context,
    # use it as the effective denominator (e.g. 1M model with 400K auto-compact).
    auto_compact=$(jq -r '.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW // empty' "$HOME/.claude/settings.json" 2>/dev/null)
    effective_size="$size"
    if [ -n "$auto_compact" ] && [ "$auto_compact" -gt 0 ] 2>/dev/null \
       && [ "$size" != "null" ] && [ "$size" -gt "$auto_compact" ] 2>/dev/null; then
        effective_size="$auto_compact"
    fi

    if [ "$effective_size" != "null" ] && [ "$effective_size" -gt 0 ] 2>/dev/null; then
        pct=$((current * 100 / effective_size))
        [ "$pct" -gt 100 ] && pct=100
        tokens=$((current / 1000))
        if [ "$effective_size" -le 200000 ]; then
            threshold=120000
        else
            threshold=200000
        fi
        if [ "$current" -ge "$threshold" ]; then
            status="$status | \033[33m$pct% (${tokens}K)\033[0m"
        else
            status="$status | $pct% (${tokens}K)"
        fi
    fi
fi

# Add block timer (call separate script with bash - no execute permission needed)
SCRIPT_DIR="$(dirname "$0")"
if [ -f "$SCRIPT_DIR/block_timer.sh" ]; then
    block=$(echo "$input" | bash "$SCRIPT_DIR/block_timer.sh")
    [ -n "$block" ] && status="$status
$block"

fi

# Add current working directory
# Use HOST_PWD env var if available (for Docker), otherwise use cwd from input
in_docker=""
if [ -n "$HOST_PWD" ]; then
    cwd="$HOST_PWD"
    in_docker=" (Docker)"
else
    cwd=$(echo "$input" | jq -r '.cwd // empty')
fi
if [ -n "$cwd" ]; then
    # Shorten home directory to ~ (handle various home patterns)
    cwd=$(echo "$cwd" | sed 's|^/Users/gang|~|' | sed 's|^/home/gang|~|' | sed 's|^/home/developer|~|')

    # Deterministic color based on path hash (same path = same color)
    # 6 distinct colors only (no bright variants which look similar)
    colors=(31 32 33 34 35 36)  # red green yellow blue magenta cyan
    hash=$(echo -n "$cwd" | md5 -q 2>/dev/null || echo -n "$cwd" | md5sum | cut -d' ' -f1)
    hash_num=$((0x${hash:0:8} % ${#colors[@]}))
    color_code=${colors[$hash_num]}

    cc_ver=$(echo "$input" | jq -r '.version // empty')
    status="$status
\033[${color_code}m${cwd}${in_docker}\033[0m${cc_ver:+ v$cc_ver}"
fi

printf "%b" "$status"
