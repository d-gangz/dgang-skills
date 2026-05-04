#!/bin/bash
# Block Timer for Claude Code Status Line
# Shows actual 5-hour rate limit usage (from rate_limits.five_hour) with reset countdown.

input=$(cat)

used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

# Field is absent until the first API response of a Pro/Max session.
if [ -z "$used" ]; then
    echo ""
    exit 0
fi

# Round to integer for the bar; keep one decimal for display.
used_int=$(printf '%.0f' "$used")
used_disp=$(printf '%.1f' "$used")
[ "$used_int" -gt 100 ] && used_int=100

# Progress bar (matches previous styling).
width=10
filled=$((used_int * width / 100))
empty=$((width - filled))

bar=''
if [ "$used_int" -ge 90 ]; then
    [ "$filled" -gt 0 ] && bar="${bar}$(printf '█%.0s' $(seq 1 $filled))"
elif [ "$used_int" -ge 70 ]; then
    [ "$filled" -gt 0 ] && bar="${bar}$(printf '▓%.0s' $(seq 1 $filled))"
else
    [ "$filled" -gt 0 ] && bar="${bar}$(printf '▒%.0s' $(seq 1 $filled))"
fi
[ "$empty" -gt 0 ] && bar="${bar}$(printf '░%.0s' $(seq 1 $empty))"

# Compute time until reset.
reset_str=""
if [ -n "$resets_at" ]; then
    now=$(date +%s)
    remaining=$((resets_at - now))
    if [ "$remaining" -gt 0 ]; then
        rh=$((remaining / 3600))
        rm=$(((remaining % 3600) / 60))
        reset_str=" · resets in ${rh}hr ${rm}m"
    fi
fi

echo "$bar ${used_disp}% used${reset_str}"
