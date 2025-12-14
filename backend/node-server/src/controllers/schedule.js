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

const upsertSchedule = async (req, res) => {

    try {
        const {
            gid,
            uid,
            title,
            start,
            end,
            location,
            isAllDay,
            note,
            colorValue,
            isDone,
            recurrenceRule,
            exceptionDateList,
            doneOccurrences,
        } = req.body;

        if (!uid || !title || !start || !end) {
            return res.status(400).json({
                error: 'Missing required fields',
                required: ['userId', 'title', 'start', 'end']
            });
        }

        const newSchedule = {
            gid,
            uid,
            title,
            start,
            end,
            location,
            isAllDay,
            note,
            colorValue,
            isDone,
            recurrenceRule: recurrenceRule || null,
            exceptionDateList: exceptionDateList || [],
            doneOccurrences: doneOccurrences || [],
        };

        console.log('POST /api/schedules - Created:', newSchedule.uid, newSchedule.title, 'for user:', newSchedule.gid);
        return apiRes(res, 201, 'Schedule created successfully', null);

    } catch (error) {
        console.error('POST /api/schedules error', error);
        return apiRes(res, 500, 'Internal server error :' + error.message, null);

    }
}


module.exports = { fetchSchedule, upsertSchedule };