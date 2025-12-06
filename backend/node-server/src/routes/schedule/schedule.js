const express = require('express');
const router = express.Router();

// Sample schedule data (will be replaced with database query later)
const sampleSchedules = [
    {
        id: "1",
        userId: "user_001", // Owner of this schedule
        title: "Team Meeting",
        start: "2025-12-04T10:00:00.000Z",
        end: "2025-12-04T11:00:00.000Z",
        recurrenceRule: "FREQ=DAILY;INTERVAL=1;COUNT=10",
        exceptionDateList: ["2025-12-08"],
        colorValue: 4282557941, // Blue - 0xFF42A5F5
        doneOccurrences: ["2025-12-04", "2025-12-05"],
        isAllDay: false,
        isDone: false
    },
    {
        id: "2",
        userId: "user_001",
        title: "Weekly Review",
        start: "2025-12-04T14:00:00.000Z",
        end: "2025-12-04T15:00:00.000Z",
        recurrenceRule: "FREQ=WEEKLY;BYDAY=MO,WE,FR;COUNT=6",
        location: "Conference Room A",
        colorValue: 4284947020, // Green - 0xFF66BB6A
        isAllDay: false,
        isDone: false
    },
    {
        id: "3",
        userId: "user_002",
        title: "Project Deadline",
        start: "2025-12-06T09:00:00.000Z",
        end: "2025-12-06T17:00:00.000Z",
        isAllDay: true,
        colorValue: 4293467984, // Red - 0xFFEF5350
        note: "Submit final report",
        isDone: false
    },
    {
        id: "4",
        userId: "user_001",
        title: "Monthly Report",
        start: "2025-12-15T10:00:00.000Z",
        end: "2025-12-15T11:30:00.000Z",
        recurrenceRule: "FREQ=MONTHLY;BYMONTHDAY=15;COUNT=6",
        colorValue: 4289420220, // Purple - 0xFFAB47BC
        location: "Head Office",
        isAllDay: false,
        isDone: false
    },
    {
        id: "5",
        userId: "user_002",
        title: "Gym Session",
        start: "2025-12-04T18:00:00.000Z",
        end: "2025-12-04T19:30:00.000Z",
        recurrenceRule: "FREQ=WEEKLY;BYDAY=TU,TH;COUNT=8",
        colorValue: 4294938179, // Orange - 0xFFFF7043
        isAllDay: false,
        isDone: false
    }
];

// GET /api/schedules - Get all schedules (optionally filtered by userId)
router.get('/', async (req, res) => {
    try {
        const { userId } = req.query;

        // Filter by userId if provided
        let data = sampleSchedules;
        if (userId) {
            data = sampleSchedules.filter(s => s.userId === userId);
        }

        return res.status(200).json({
            data,
            meta: { count: data.length }
        });
    } catch (err) {
        console.error('GET /api/schedules error', err);
        return res.status(500).json({ error: 'Failed to load schedules' });
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
            id: newId,
            userId,
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
        sampleSchedules.push(newSchedule);

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
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const schedule = sampleSchedules.find(s => s.id === id);

        if (!schedule) {
            return res.status(404).json({ error: 'Schedule not found' });
        }

        return res.status(200).json({ data: schedule });
    } catch (err) {
        console.error('GET /api/schedules/:id error', err);
        return res.status(500).json({ error: 'Failed to load schedule' });
    }
});

// PUT /api/schedules/:id - Update an existing schedule
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
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

        // Validate userId is provided
        if (!userId) {
            return res.status(400).json({ error: 'userId is required' });
        }

        // Find the schedule index
        const index = sampleSchedules.findIndex(s => s.id === id);

        if (index === -1) {
            return res.status(404).json({ error: 'Schedule not found' });
        }

        // Validate ownership - user can only update their own schedules
        const existingSchedule = sampleSchedules[index];
        if (existingSchedule.userId !== userId) {
            return res.status(403).json({ error: 'You do not have permission to update this schedule' });
        }

        // Update the schedule (merge with existing data)
        const updatedSchedule = {
            ...existingSchedule,
            title: title ?? existingSchedule.title,
            start: start ?? existingSchedule.start,
            end: end ?? existingSchedule.end,
            recurrenceRule: recurrenceRule !== undefined ? recurrenceRule : existingSchedule.recurrenceRule,
            exceptionDateList: exceptionDateList !== undefined ? exceptionDateList : existingSchedule.exceptionDateList,
            colorValue: colorValue ?? existingSchedule.colorValue,
            doneOccurrences: doneOccurrences !== undefined ? doneOccurrences : existingSchedule.doneOccurrences,
            isAllDay: isAllDay !== undefined ? isAllDay : existingSchedule.isAllDay,
            isDone: isDone !== undefined ? isDone : existingSchedule.isDone,
            location: location !== undefined ? location : existingSchedule.location,
            note: note !== undefined ? note : existingSchedule.note
        };

        // Replace in array
        sampleSchedules[index] = updatedSchedule;

        console.log('PUT /api/schedules/:id - Updated:', id, updatedSchedule.title, 'by user:', userId);

        return res.status(200).json({
            data: updatedSchedule,
            message: 'Schedule updated successfully'
        });
    } catch (err) {
        console.error('PUT /api/schedules/:id error', err);
        return res.status(500).json({ error: 'Failed to update schedule' });
    }
});

// DELETE /api/schedules/:id - Delete a schedule
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { userId } = req.query; // Pass userId as query param for DELETE

        // Validate userId is provided
        if (!userId) {
            return res.status(400).json({ error: 'userId is required as query parameter' });
        }

        // Find the schedule index
        const index = sampleSchedules.findIndex(s => s.id === id);

        if (index === -1) {
            return res.status(404).json({ error: 'Schedule not found' });
        }

        // Validate ownership - user can only delete their own schedules
        const existingSchedule = sampleSchedules[index];
        if (existingSchedule.userId !== userId) {
            return res.status(403).json({ error: 'You do not have permission to delete this schedule' });
        }

        // Remove from array
        const deletedSchedule = sampleSchedules.splice(index, 1)[0];

        console.log('DELETE /api/schedules/:id - Deleted:', id, deletedSchedule.title, 'by user:', userId);

        return res.status(200).json({
            message: 'Schedule deleted successfully',
            data: { id: deletedSchedule.id }
        });
    } catch (err) {
        console.error('DELETE /api/schedules/:id error', err);
        return res.status(500).json({ error: 'Failed to delete schedule' });
    }
});

module.exports = router;