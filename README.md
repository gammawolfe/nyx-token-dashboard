# 🌙 Nyx Token Dashboard

Real-time token consumption monitoring dashboard for OpenClaw.

**Live Dashboard:** [https://gammawolfe.github.io/nyx-token-dashboard/](https://gammawolfe.github.io/nyx-token-dashboard/)

## Features

- **Live Token Tracking**: Input/output token counts over time
- **Context Usage**: Visual progress bar and chart showing context consumption  
- **Model Info**: Current model and session uptime
- **Auto-refresh**: Updates every 5 seconds from GitHub Pages
- **No Backend Required**: Pure static site hosted on GitHub Pages

## How It Works

1. Nyx periodically captures session stats via `session_status`
2. Stats are appended to `stats.json`
3. Auto-commit and push to GitHub (via `auto-update.sh`)
4. GitHub Pages serves the updated dashboard globally
5. Dashboard auto-refreshes to show latest data

## Updating Stats

### Automatic (Recommended)
Nyx can update stats during heartbeats or on request:

```bash
cd /data/.openclaw/workspace/token-dashboard
./auto-update.sh <tokens_in> <tokens_out> <context_percent> <context_used> <context_total> <model> <uptime>
```

Example:
```bash
./auto-update.sh 1000 500 8 16 200 "grok-4.1-fast" "5m ago"
```

### Manual
Edit `stats.json` and push:
```bash
git add stats.json
git commit -m "📊 Update stats"
git push origin main
```

GitHub Pages will rebuild in ~30 seconds.

## Files

- `index.html` - Dashboard UI (static HTML + Chart.js)
- `stats.json` - Stats data (auto-updated)
- `auto-update.sh` - Auto-commit and push script
- `server.js` - Optional local dev server
- `README.md` - This file

## Local Development

Run a local server (optional):
```bash
node server.js
# or
python3 -m http.server 8889
```

Visit `http://localhost:8889`

---

Built with Chart.js for clean, animated visualizations. Hosted on GitHub Pages for global access.
