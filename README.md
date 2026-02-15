# 🌙 Nyx Token Dashboard

Real-time token consumption monitoring dashboard for OpenClaw.

## Features

- **Live Token Tracking**: Input/output token counts over time
- **Context Usage**: Visual progress bar and chart showing context consumption
- **Model Info**: Current model and session uptime
- **Auto-refresh**: Updates every 2 seconds

## Running the Dashboard

### Start the server:
```bash
cd /data/.openclaw/workspace/token-dashboard
node server.js
```

The dashboard will be available at: `http://localhost:8889`

### Updating Stats

Stats are stored in `stats.json`. To add a new entry, POST to `/api/update`:

```bash
curl -X POST http://localhost:8889/api/update \
  -H "Content-Type: application/json" \
  -d '{
    "timestamp": "2026-02-15T01:00:00Z",
    "tokens": { "in": 1000, "out": 500 },
    "context": { "used": 16, "total": 200, "percent": 8 },
    "model": "openrouter/x-ai/grok-4.1-fast",
    "uptime": "5 minutes ago"
  }'
```

Nyx can update this automatically during heartbeats or on request.

## Files

- `index.html` - Dashboard UI
- `server.js` - Node.js server
- `stats.json` - Stats data (auto-generated)
- `README.md` - This file

Built with Chart.js for clean, animated visualizations.
