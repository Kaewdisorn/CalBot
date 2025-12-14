-- Convert string to UUID
SELECT v1.uuid_generate_v5 (v1.uuid_ns_url(), 'calbot_user_guest' );

-- Generate random UUID
SELECT gen_random_uuid ();

-- Upsert User
INSERT INTO ${FULL_TABLE} (gid, uid, properties)
VALUES ($1, $2, $3)
ON CONFLICT (gid, uid) DO UPDATE
SET
    gid         = EXCLUDED.gid,
    properties  = EXCLUDED.properties,
    updated_at  = CURRENT_TIMESTAMP
RETURNING
    gid,
    uid,
    properties,
    created_at,
    updated_at;

-- Upsert Schedule
INSERT INTO v1.schedules
(gid, uid, properties, created_at, updated_at)
VALUES(?, ?, '{}'::jsonb, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (uid)
DO UPDATE SET
    properties = EXCLUDED.properties,
    updated_at = CURRENT_TIMESTAMP;

/* Sample Schedule Data for Testing */
-- Insert Team Meeting
INSERT INTO v1.schedules (gid, uid, properties)
VALUES (
    'a3dfbd82-dedb-5577-bdc1-45d9e74cc5a4',
    (SELECT gen_random_uuid()),
    '{
        "title": "Team Meeting",
        "start": "2025-12-04T10:00:00.000Z",
        "end": "2025-12-04T11:00:00.000Z",
        "recurrenceRule": "FREQ=DAILY;INTERVAL=1;COUNT=10",
        "exceptionDateList": ["2025-12-08"],
        "colorValue": 4282557941,
        "doneOccurrences": ["2025-12-04", "2025-12-05"],
        "isAllDay": false,
        "isDone": false
    }'::jsonb
);

-- Insert Weekly Review
INSERT INTO v1.schedules (gid, uid, properties)
VALUES (
    'a3dfbd82-dedb-5577-bdc1-45d9e74cc5a4',
    (SELECT gen_random_uuid()),
    '{
        "title": "Weekly Review",
        "start": "2025-12-04T14:00:00.000Z",
        "end": "2025-12-04T15:00:00.000Z",
        "recurrenceRule": "FREQ=WEEKLY;BYDAY=MO,WE,FR;COUNT=6",
        "location": "Conference Room A",
        "colorValue": 4284947020,
        "isAllDay": false,
        "isDone": false
    }'::jsonb
);

-- Insert Project Deadline
INSERT INTO v1.schedules (gid, uid, properties)
VALUES (
    'a3dfbd82-dedb-5577-bdc1-45d9e74cc5a4',
    (SELECT gen_random_uuid()),
    '{
        "title": "Project Deadline",
        "start": "2025-12-06T09:00:00.000Z",
        "end": "2025-12-06T17:00:00.000Z",
        "isAllDay": true,
        "colorValue": 4293467984,
        "note": "Submit final report",
        "isDone": false
    }'::jsonb
);

-- Insert Monthly Report
INSERT INTO v1.schedules (gid, uid, properties)
VALUES (
    'a3dfbd82-dedb-5577-bdc1-45d9e74cc5a4',
    (SELECT gen_random_uuid()),
    '{
        "title": "Monthly Report",
        "start": "2025-12-15T10:00:00.000Z",
        "end": "2025-12-15T11:30:00.000Z",
        "recurrenceRule": "FREQ=MONTHLY;BYMONTHDAY=15;COUNT=6",
        "colorValue": 4289420220,
        "location": "Head Office",
        "isAllDay": false,
        "isDone": false
    }'::jsonb
);

-- Insert Gym Session
INSERT INTO v1.schedules (gid, uid, properties)
VALUES (
    'a3dfbd82-dedb-5577-bdc1-45d9e74cc5a4',
    (SELECT gen_random_uuid()),
    '{
        "title": "Gym Session",
        "start": "2025-12-04T18:00:00.000Z",
        "end": "2025-12-04T19:30:00.000Z",
        "recurrenceRule": "FREQ=WEEKLY;BYDAY=TU,TH;COUNT=8",
        "colorValue": 4294938179,
        "isAllDay": false,
        "isDone": false
    }'::jsonb
);

-- Select all schedules for an user
SELECT gid, uid, properties, created_at, updated_at
FROM v1.schedules s 
WHERE gid = 'a3dfbd82-dedb-5577-bdc1-45d9e74cc5a4'
ORDER BY (properties->>'start')::timestamptz ASC