const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
    console.log('GET /api/schedules called');
    res.json({ status: "ok" });
});

module.exports = router;