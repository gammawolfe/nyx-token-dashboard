#!/usr/bin/env python3
"""
Token Dashboard Monitor
Polls session status and updates stats.json for the dashboard
"""

import json
import time
import subprocess
import re
from datetime import datetime
from pathlib import Path

STATS_FILE = Path("/data/.openclaw/workspace/token-dashboard/stats.json")
POLL_INTERVAL = 2  # seconds
MAX_HISTORY = 500  # Keep last 500 entries

def parse_session_status():
    """Call openclaw to get session status and parse it."""
    try:
        # Use openclaw CLI to get session status
        # We'll parse the output to extract token counts
        result = subprocess.run(
            ["openclaw", "session", "status"],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        output = result.stdout
        
        # Parse tokens: "🧮 Tokens: 10 in / 203 out"
        tokens_match = re.search(r'Tokens:\s*(\d+)\s*in\s*/\s*(\d+)\s*out', output)
        if not tokens_match:
            return None
            
        tokens_in = int(tokens_match.group(1))
        tokens_out = int(tokens_match.group(2))
        
        # Parse context: "📚 Context: 16k/200k (8%)"
        context_match = re.search(r'Context:\s*(\d+)k?/(\d+)k?\s*\((\d+)%\)', output)
        if not context_match:
            return None
            
        context_used = int(context_match.group(1))
        context_total = int(context_match.group(2))
        context_percent = int(context_match.group(3))
        
        # Parse model: "🧠 Model: openrouter/x-ai/grok-4.1-fast"
        model_match = re.search(r'Model:\s*([^\s·]+)', output)
        model = model_match.group(1) if model_match else "unknown"
        
        # Parse session update time for uptime calculation
        uptime_match = re.search(r'updated\s+(.*?)(?:\n|$)', output)
        uptime = uptime_match.group(1) if uptime_match else "unknown"
        
        return {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "tokens": {
                "in": tokens_in,
                "out": tokens_out
            },
            "context": {
                "used": context_used,
                "total": context_total,
                "percent": context_percent
            },
            "model": model,
            "uptime": uptime
        }
        
    except Exception as e:
        print(f"Error getting session status: {e}")
        return None

def update_stats(new_entry):
    """Add new entry to stats history."""
    if not new_entry:
        return
        
    # Read existing stats
    if STATS_FILE.exists():
        with open(STATS_FILE, 'r') as f:
            stats = json.load(f)
    else:
        stats = {"history": []}
    
    # Add new entry
    stats["history"].append(new_entry)
    
    # Trim history if too long
    if len(stats["history"]) > MAX_HISTORY:
        stats["history"] = stats["history"][-MAX_HISTORY:]
    
    # Write back
    STATS_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(STATS_FILE, 'w') as f:
        json.dump(stats, f, indent=2)

def main():
    print("🌙 Nyx Token Monitor starting...")
    print(f"Polling every {POLL_INTERVAL}s")
    print(f"Stats file: {STATS_FILE}")
    
    while True:
        entry = parse_session_status()
        if entry:
            update_stats(entry)
            print(f"✓ {entry['timestamp']} | Tokens: {entry['tokens']['in']}↓ {entry['tokens']['out']}↑ | Context: {entry['context']['percent']}%")
        else:
            print("✗ Failed to get session status")
        
        time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n🌙 Monitor stopped")
