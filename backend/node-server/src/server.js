require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// -------------------------------
// Middlewares
// -------------------------------
app.use(cors());
app.use(express.json());

// -------------------------------
// Serve Flutter Web build
// -------------------------------
const flutterBuildPath = path.join(__dirname, '..', '..', '..', 'frontend', 'build', 'web');
app.use(express.static(flutterBuildPath));

// -------------------------------
// API Routes
// -------------------------------
app.get('/api/ping', (req, res) => {
  res.json({ success: true, message: 'CalBot backend is running!' });
});

// Example: additional API routes can go here
// const scheduleRouter = require('../routes/schedule');
// app.use('/api/schedule', scheduleRouter);

// -------------------------------
// Catch-all route for Flutter SPA
// -------------------------------
app.get(/^\/(?!api).*/, (req, res) => {
  res.sendFile(path.join(flutterBuildPath, 'index.html'));
});

// -------------------------------
// Start server
// -------------------------------
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
