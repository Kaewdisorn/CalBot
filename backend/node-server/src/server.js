require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// Routes
// const scheduleRouter = require('./routes/schedule');
// app.use('/api/schedule', scheduleRouter);

// Test route
app.get('/', (req, res) => {
  res.send('CalBot backend is running!');
});

// Start server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
