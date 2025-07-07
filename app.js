const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 4000;

app.use(express.static('public'));

let requestCount = 0;
let errorCount = 0;
const startTime = Date.now();

app.use((req, res, next) => {
  requestCount++;
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} - Request #${requestCount}`);
  next();
});

// Main route
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});


app.get('/health', (req, res) => {
  const uptime = Date.now() - startTime;
  res.json({
    status: 'OK',
    uptime: `${Math.floor(uptime / 1000)} seconds`,
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});


app.get('/api/stats', (req, res) => {
  res.json({
    totalRequests: requestCount,
    totalErrors: errorCount,
    uptime: Date.now() - startTime,
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString()
  });
});


app.get('/api/error', (req, res) => {
  errorCount++;
  console.error(`[${new Date().toISOString()}] ERROR: Simulated error endpoint called`);
  res.status(500).json({ error: 'Simulated error', timestamp: new Date().toISOString() });
});


app.get('/api/slow', (req, res) => {
  setTimeout(() => {
    res.json({ 
      message: 'This was a slow response', 
      delay: '2 seconds',
      timestamp: new Date().toISOString() 
    });
  }, 2000);
});


app.use((req, res) => {
  errorCount++;
  res.status(404).json({ 
    error: 'Not Found', 
    path: req.url,
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`🚀 DevOps 1 App running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`📈 Stats: http://localhost:${PORT}/api/stats`);
});
