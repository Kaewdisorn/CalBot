const express = require('express');
const router = express.Router();
const scheduleRepository = require('../../repositories/schedule.repository');

// =============================================================================
// GET /api/schedules - Get all schedules for a user (filtered by gid)
// =============================================================================
router.get('/', async (req, res) => {
    try {
        const { gid } = req.query;

        if (!gid) {
            return res.status(400).json({
                error: 'Missing required query parameter: gid',
                required: ['gid']
            });
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
});

// POST /api/schedules - Create a new schedule
router.post('/', async (req, res) => {
    try {
        const {
            userId,
            title,
            start,
            end,
            recurrenceRule,
            exceptionDateList,
            colorValue,
            doneOccurrences,
            isAllDay,
            isDone,
            location,
            note
        } = req.body;

        // Validate required fields
        if (!userId || !title || !start || !end) {
            return res.status(400).json({
                error: 'Missing required fields',
                required: ['userId', 'title', 'start', 'end']
            });
        }

        // Generate a new ID (temporary - will use database auto-increment later)
        const newId = String(Date.now()); // Use timestamp for unique ID

        // Create new schedule object
        const newSchedule = {
            uid: newId,
            gid: userId,
            title,
            start,
            end,
            recurrenceRule: recurrenceRule || null,
            exceptionDateList: exceptionDateList || [],
            colorValue: colorValue || 4282557941, // Default blue
            doneOccurrences: doneOccurrences || [],
            isAllDay: isAllDay || false,
            isDone: isDone || false,
            location: location || null,
            note: note || null
        };

        // Add to sample data (temporary - will insert into database later)
        // sampleSchedules.push(newSchedule);

        console.log('POST /api/schedules - Created:', newSchedule.id, newSchedule.title, 'for user:', userId);

        return res.status(201).json({
            data: newSchedule,
            message: 'Schedule created successfully'
        });
    } catch (err) {
        console.error('POST /api/schedules error', err);
        return res.status(500).json({ error: 'Failed to create schedule' });
    }
});

// GET /api/schedules/:id - Get a single schedule by ID
// router.get('/:id', async (req, res) => {
//     try {
//         const { id } = req.params;

//         const schedule = sampleSchedules.find(s => s.id === id);

//         if (!schedule) {
//             return res.status(404).json({ error: 'Schedule not found' });
//         }

//         return res.status(200).json({ data: schedule });
//     } catch (err) {
//         console.error('GET /api/schedules/:id error', err);
//         return res.status(500).json({ error: 'Failed to load schedule' });
//     }
// });

// PUT /api/schedules/:id - Update an existing schedule
// router.put('/:id', async (req, res) => {
//     try {
//         const { id } = req.params;
//         const {
//             userId,
//             title,
//             start,
//             end,
//             recurrenceRule,
//             exceptionDateList,
//             colorValue,
//             doneOccurrences,
//             isAllDay,
//             isDone,
//             location,
//             note
//         } = req.body;

//         // Validate userId is provided
//         if (!userId) {
//             return res.status(400).json({ error: 'userId is required' });
//         }

//         // Find the schedule index
//         const index = sampleSchedules.findIndex(s => s.id === id);

//         if (index === -1) {
//             return res.status(404).json({ error: 'Schedule not found' });
//         }

//         // Validate ownership - user can only update their own schedules
//         const existingSchedule = sampleSchedules[index];
//         if (existingSchedule.userId !== userId) {
//             return res.status(403).json({ error: 'You do not have permission to update this schedule' });
//         }

//         // Update the schedule (merge with existing data)
//         const updatedSchedule = {
//             ...existingSchedule,
//             title: title ?? existingSchedule.title,
//             start: start ?? existingSchedule.start,
//             end: end ?? existingSchedule.end,
//             recurrenceRule: recurrenceRule !== undefined ? recurrenceRule : existingSchedule.recurrenceRule,
//             exceptionDateList: exceptionDateList !== undefined ? exceptionDateList : existingSchedule.exceptionDateList,
//             colorValue: colorValue ?? existingSchedule.colorValue,
//             doneOccurrences: doneOccurrences !== undefined ? doneOccurrences : existingSchedule.doneOccurrences,
//             isAllDay: isAllDay !== undefined ? isAllDay : existingSchedule.isAllDay,
//             isDone: isDone !== undefined ? isDone : existingSchedule.isDone,
//             location: location !== undefined ? location : existingSchedule.location,
//             note: note !== undefined ? note : existingSchedule.note
//         };

//         // Replace in array
//         sampleSchedules[index] = updatedSchedule;

//         console.log('PUT /api/schedules/:id - Updated:', id, updatedSchedule.title, 'by user:', userId);

//         return res.status(200).json({
//             data: updatedSchedule,
//             message: 'Schedule updated successfully'
//         });
//     } catch (err) {
//         console.error('PUT /api/schedules/:id error', err);
//         return res.status(500).json({ error: 'Failed to update schedule' });
//     }
// });

// DELETE /api/schedules/:id - Delete a schedule
// router.delete('/:id', async (req, res) => {
//     try {
//         const { id } = req.params;
//         const { userId } = req.query; // Pass userId as query param for DELETE

//         // Validate userId is provided
//         if (!userId) {
//             return res.status(400).json({ error: 'userId is required as query parameter' });
//         }

//         // Find the schedule index
//         const index = sampleSchedules.findIndex(s => s.id === id);

//         if (index === -1) {
//             return res.status(404).json({ error: 'Schedule not found' });
//         }

//         // Validate ownership - user can only delete their own schedules
//         const existingSchedule = sampleSchedules[index];
//         if (existingSchedule.userId !== userId) {
//             return res.status(403).json({ error: 'You do not have permission to delete this schedule' });
//         }

//         // Remove from array
//         const deletedSchedule = sampleSchedules.splice(index, 1)[0];

//         console.log('DELETE /api/schedules/:id - Deleted:', id, deletedSchedule.title, 'by user:', userId);

//         return res.status(200).json({
//             message: 'Schedule deleted successfully',
//             data: { id: deletedSchedule.id }
//         });
//     } catch (err) {
//         console.error('DELETE /api/schedules/:id error', err);
//         return res.status(500).json({ error: 'Failed to delete schedule' });
//     }
// });

module.exports = router;