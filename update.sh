#!/bin/bash

# Quick update script for token dashboard
# Usage: ./update.sh <tokens_in> <tokens_out> <context_percent> <context_used> <context_total> <model> <uptime>

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

TOKENS_IN=${1:-0}
TOKENS_OUT=${2:-0}
CONTEXT_PERCENT=${3:-0}
CONTEXT_USED=${4:-0}
CONTEXT_TOTAL=${5:-200}
MODEL=${6:-"unknown"}
UPTIME=${7:-"unknown"}

curl -X POST http://localhost:8889/api/update \
  -H "Content-Type: application/json" \
  -s \
  -d "{
    \"timestamp\": \"$TIMESTAMP\",
    \"tokens\": { \"in\": $TOKENS_IN, \"out\": $TOKENS_OUT },
    \"context\": { \"used\": $CONTEXT_USED, \"total\": $CONTEXT_TOTAL, \"percent\": $CONTEXT_PERCENT },
    \"model\": \"$MODEL\",
    \"uptime\": \"$UPTIME\"
  }"

echo ""
echo "✓ Dashboard updated: $TOKENS_IN in / $TOKENS_OUT out | Context: $CONTEXT_PERCENT%"
