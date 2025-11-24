require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

const apiRoutes = require('./routes/api.js');

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
const flutterBuildPath = path.join(__dirname, '..', '..', '..', 'frontend', 'flutter-build', 'web');
app.use(express.static(flutterBuildPath));

// -------------------------------
// API Routes
// -------------------------------
app.use('/api', apiRoutes); 


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
