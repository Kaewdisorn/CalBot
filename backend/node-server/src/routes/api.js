const express = require('express');
const router = express.Router();

const healthRoutes = require('./health/health.js');
const scheduleRoutes = require('./schedule/schedule.js');

router.use('/health', healthRoutes);
router.use('/schedules', scheduleRoutes);

module.exports = router;
