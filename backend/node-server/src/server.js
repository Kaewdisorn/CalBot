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
// Serve Flutter Web build with cache control
// -------------------------------
const flutterBuildPath = path.join(__dirname, '..', '..', '..', 'frontend', 'build', 'web');

app.use(express.static(flutterBuildPath, {
  setHeaders: (res, filePath) => {
    // No cache for index.html - always fetch latest version
    if (filePath.endsWith('index.html')) {
      res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
      res.setHeader('Pragma', 'no-cache');
      res.setHeader('Expires', '0');
    }
    // Short cache for JS/CSS files (5 minutes)
    else if (filePath.match(/\.(js|css)$/)) {
      res.setHeader('Cache-Control', 'public, max-age=300');
    }
    // Longer cache for images and fonts (1 hour)
    else if (filePath.match(/\.(png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$/)) {
      res.setHeader('Cache-Control', 'public, max-age=3600');
    }
  }
}));

// -------------------------------
// API Routes
// -------------------------------
app.use('/api', apiRoutes);


// -------------------------------
// Catch-all route for Flutter SPA
// -------------------------------
app.get(/^\/(?!api).*/, (req, res) => {
  // Set no-cache headers for SPA routing
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('Expires', '0');

  res.sendFile(path.join(flutterBuildPath, 'index.html'));
});

// -------------------------------
// Start server
// -------------------------------
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});