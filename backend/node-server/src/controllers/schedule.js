const scheduleRepository = require('../repositories/schedule');
const { apiRes } = require('../utils/response');

const fetchSchedule = async (req, res) => {

    try {
        const { gid } = req.query;

        if (!gid) {
            return apiRes(res, 400, 'Missing required query parameter: gid', null);
        }

        // ============ DATABASE QUERY ============
        console.log(`📊 Fetching schedules from database for gid: ${gid}`);
        let data = await scheduleRepository.getSchedules(gid, null);
        console.log(`✅ Found ${data.length} schedules in database`);

        return res.status(200).json({
            data,
            meta: {
                count: data.length,
                source: 'database'
            }
        });
    } catch (err) {
        console.error('GET /api/schedules error:', err);
        return res.status(500).json({
            error: 'Failed to load schedules',
            details: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};


module.exports = { fetchSchedule };