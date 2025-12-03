const express = require('express');
const router = express.Router();

// Sample schedule data (will be replaced with database query later)
const sampleSchedules = [
    {
        id: "1",
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
        title: "Gym Session",
        start: "2025-12-04T18:00:00.000Z",
        end: "2025-12-04T19:30:00.000Z",
        recurrenceRule: "FREQ=WEEKLY;BYDAY=TU,TH;COUNT=8",
        colorValue: 4294938179, // Orange - 0xFFFF7043
        isAllDay: false,
        isDone: false
    }
];

// GET /api/schedules - Get all schedules
router.get('/', async (_req, res) => {
    try {

        const data = sampleSchedules;

        return res.status(200).json({
            data,
            meta: { count: data.length }
        });
    } catch (err) {
        console.error('GET /api/schedules error', err);
        return res.status(500).json({ error: 'Failed to load schedules' });
    }
});

module.exports = router;