#!/bin/bash

# Auto-update script for GitHub Pages dashboard
# Fetches current session stats and pushes to GitHub

cd /data/.openclaw/workspace/token-dashboard

# This will be called with session stats as arguments
# Usage: ./auto-update.sh <tokens_in> <tokens_out> <context_percent> <context_used> <context_total> <model> <uptime>

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TOKENS_IN=${1:-0}
TOKENS_OUT=${2:-0}
CONTEXT_PERCENT=${3:-0}
CONTEXT_USED=${4:-0}
CONTEXT_TOTAL=${5:-200}
MODEL=${6:-"unknown"}
UPTIME=${7:-"unknown"}

# Read current stats
STATS=$(cat stats.json)

# Add new entry using jq (if available) or python
if command -v jq &> /dev/null; then
    # Use jq
    NEW_ENTRY=$(cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "tokens": { "in": $TOKENS_IN, "out": $TOKENS_OUT },
  "context": { "used": $CONTEXT_USED, "total": $CONTEXT_TOTAL, "percent": $CONTEXT_PERCENT },
  "model": "$MODEL",
  "uptime": "$UPTIME"
}
EOF
)
    echo "$STATS" | jq ".history += [$NEW_ENTRY] | .history |= .[-500:]" > stats.json
else
    # Use python
    python3 << EOF
import json

with open('stats.json', 'r') as f:
    stats = json.load(f)

new_entry = {
    "timestamp": "$TIMESTAMP",
    "tokens": { "in": $TOKENS_IN, "out": $TOKENS_OUT },
    "context": { "used": $CONTEXT_USED, "total": $CONTEXT_TOTAL, "percent": $CONTEXT_PERCENT },
    "model": "$MODEL",
    "uptime": "$UPTIME"
}

stats['history'].append(new_entry)
stats['history'] = stats['history'][-500:]  # Keep last 500

with open('stats.json', 'w') as f:
    json.dump(stats, f, indent=2)
EOF
fi

# Commit and push
git add stats.json
git commit -m "📊 Auto-update stats: ${TOKENS_IN}↓ ${TOKENS_OUT}↑ | ${CONTEXT_PERCENT}% context" --quiet
git push origin main --quiet 2>&1 | grep -v "Everything up-to-date" || true

echo "✓ Stats updated and pushed to GitHub Pages"
