#!/usr/bin/env node

/**
 * Token Dashboard Server
 * Serves the dashboard and provides a stats API endpoint
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8889;
const STATS_FILE = path.join(__dirname, 'stats.json');

// Initialize stats file if it doesn't exist
if (!fs.existsSync(STATS_FILE)) {
    fs.writeFileSync(STATS_FILE, JSON.stringify({ history: [] }, null, 2));
}

// Serve static files and API
const server = http.createServer((req, res) => {
    console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
    
    // API endpoint to get stats
    if (req.url === '/api/stats' || req.url === '/stats.json') {
        res.writeHead(200, { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        });
        const stats = fs.readFileSync(STATS_FILE, 'utf8');
        res.end(stats);
        return;
    }
    
    // API endpoint to update stats (POST)
    if (req.url === '/api/update' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            try {
                const newEntry = JSON.parse(body);
                const stats = JSON.parse(fs.readFileSync(STATS_FILE, 'utf8'));
                stats.history.push(newEntry);
                
                // Keep last 500 entries
                if (stats.history.length > 500) {
                    stats.history = stats.history.slice(-500);
                }
                
                fs.writeFileSync(STATS_FILE, JSON.stringify(stats, null, 2));
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: true }));
                console.log('✓ Stats updated');
            } catch (error) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: error.message }));
            }
        });
        return;
    }
    
    // Serve static files
    let filePath = req.url === '/' ? '/index.html' : req.url;
    filePath = path.join(__dirname, filePath);
    
    const extname = path.extname(filePath);
    const contentTypes = {
        '.html': 'text/html',
        '.js': 'text/javascript',
        '.css': 'text/css',
        '.json': 'application/json',
    };
    const contentType = contentTypes[extname] || 'text/plain';
    
    fs.readFile(filePath, (error, content) => {
        if (error) {
            if (error.code === 'ENOENT') {
                res.writeHead(404);
                res.end('404 Not Found');
            } else {
                res.writeHead(500);
                res.end('500 Internal Server Error');
            }
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content);
        }
    });
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`🌙 Token Dashboard running at http://0.0.0.0:${PORT}`);
    console.log(`   Access stats at http://0.0.0.0:${PORT}/stats.json`);
    console.log(`   Update via POST to http://0.0.0.0:${PORT}/api/update`);
});
