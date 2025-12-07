
const { query } = require('../config/database');

const SCHEMA = 'v1';
const TABLE = 'schedules';
const FULL_TABLE = `${SCHEMA}.${TABLE}`;

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/**
 * Transform database row to API response format
 * Extracts properties from JSONB and flattens the structure
 * 
 * @param {Object} row - Database row with gid, uid, properties, timestamps
 * @returns {Object} - Flattened schedule object for API response
 */
const transformRowToSchedule = (row) => {
    if (!row) return null;
    const { gid, uid, properties, created_at, updated_at } = row;

    return {
        gid,
        uid,
        title: properties?.title || '',
        start: properties?.start || null,
        end: properties?.end || null,
        location: properties?.location || null,
        isAllDay: properties?.isAllDay || false,
        note: properties?.note || null,
        colorValue: properties?.colorValue || 4282557941, // Default blue
        recurrenceRule: properties?.recurrenceRule || null,
        exceptionDateList: properties?.exceptionDateList || [],
        isDone: properties?.isDone || false,
        doneOccurrences: properties?.doneOccurrences || [],
        createdAt: created_at,
        updatedAt: updated_at,
    };
};

/**
 * Transform multiple rows
 * @param {Array} rows - Array of database rows
 * @returns {Array} - Array of transformed schedule objects
 */
const transformRowsToSchedules = (rows) => {
    return rows.map(transformRowToSchedule);
};

// =============================================================================
// REPOSITORY METHODS
// =============================================================================

const getSchedules = async (gid, uid) => {


    if (gid != null && uid != null) {
        // Get specific schedule by uid and gid
        const sql = `
        SELECT gid, uid, properties, created_at, updated_at
        FROM ${FULL_TABLE}
        WHERE uid = $1 AND gid = $2
    `;
        const result = await query(sql, [uid, gid]);
        return result.rows.length > 0 ? transformRowToSchedule(result.rows[0]) : null;

    } else {
        // Get all schedules for gid
        const sql = `
        SELECT gid, uid, properties, created_at, updated_at
        FROM ${FULL_TABLE}
        WHERE gid = $1
        ORDER BY (properties->>'start')::timestamptz ASC
    `;
        const result = await query(sql, [gid]);
        return transformRowsToSchedules(result.rows);
    }
};


/**
 * Create a new schedule
 * 
 * @param {string} gid - Group/User UUID (owner)
 * @param {Object} scheduleData - Schedule properties (title, start, end, etc.)
 * @returns {Promise<Object>} - Created schedule object
 * 
 * @example
 * const newSchedule = await create('user-uuid', {
 *   title: 'Team Meeting',
 *   start: '2025-12-10T09:00:00.000Z',
 *   end: '2025-12-10T10:00:00.000Z',
 *   isAllDay: false
 * });
 */
const create = async (gid, scheduleData) => {
    const sql = `
        INSERT INTO ${FULL_TABLE} (gid, uid, properties)
        VALUES ($1, uuid_generate_v4(), $2)
        RETURNING gid, uid, properties, created_at, updated_at
    `;

    const properties = {
        title: scheduleData.title,
        start: scheduleData.start,
        end: scheduleData.end,
        location: scheduleData.location || null,
        isAllDay: scheduleData.isAllDay || false,
        note: scheduleData.note || null,
        colorValue: scheduleData.colorValue || 4282557941,
        recurrenceRule: scheduleData.recurrenceRule || null,
        exceptionDateList: scheduleData.exceptionDateList || [],
        isDone: scheduleData.isDone || false,
        doneOccurrences: scheduleData.doneOccurrences || [],
    };

    const result = await query(sql, [gid, JSON.stringify(properties)]);
    return transformRowToSchedule(result.rows[0]);
};

/**
 * Update an existing schedule
 * 
 * @param {string} uid - Schedule UUID
 * @param {string} gid - Group/User UUID (for ownership verification)
 * @param {Object} updateData - Fields to update
 * @returns {Promise<Object|null>} - Updated schedule or null if not found/not owned
 */
const update = async (uid, gid, updateData) => {
    // First, get existing schedule to merge properties
    const existing = await getSchedules(uid, gid);
    if (!existing) return null;

    // Merge existing properties with updates
    const mergedProperties = {
        title: updateData.title ?? existing.title,
        start: updateData.start ?? existing.start,
        end: updateData.end ?? existing.end,
        location: updateData.location !== undefined ? updateData.location : existing.location,
        isAllDay: updateData.isAllDay !== undefined ? updateData.isAllDay : existing.isAllDay,
        note: updateData.note !== undefined ? updateData.note : existing.note,
        colorValue: updateData.colorValue ?? existing.colorValue,
        recurrenceRule: updateData.recurrenceRule !== undefined ? updateData.recurrenceRule : existing.recurrenceRule,
        exceptionDateList: updateData.exceptionDateList !== undefined ? updateData.exceptionDateList : existing.exceptionDateList,
        isDone: updateData.isDone !== undefined ? updateData.isDone : existing.isDone,
        doneOccurrences: updateData.doneOccurrences !== undefined ? updateData.doneOccurrences : existing.doneOccurrences,
    };

    const sql = `
        UPDATE ${FULL_TABLE}
        SET properties = $1, updated_at = CURRENT_TIMESTAMP
        WHERE uid = $2 AND gid = $3
        RETURNING gid, uid, properties, created_at, updated_at
    `;

    const result = await query(sql, [JSON.stringify(mergedProperties), uid, gid]);
    return result.rows.length > 0 ? transformRowToSchedule(result.rows[0]) : null;
};

/**
 * Delete a schedule
 * 
 * @param {string} uid - Schedule UUID
 * @param {string} gid - Group/User UUID (for ownership verification)
 * @returns {Promise<boolean>} - True if deleted, false if not found/not owned
 */
const remove = async (uid, gid) => {
    const sql = `
        DELETE FROM ${FULL_TABLE}
        WHERE uid = $1 AND gid = $2
        RETURNING uid
    `;

    const result = await query(sql, [uid, gid]);
    return result.rowCount > 0;
};

/**
 * Count schedules for a user
 * 
 * @param {string} gid - Group/User UUID
 * @returns {Promise<number>} - Number of schedules
 */
const countByGid = async (gid) => {
    const sql = `
        SELECT COUNT(*) as count
        FROM ${FULL_TABLE}
        WHERE gid = $1
    `;

    const result = await query(sql, [gid]);
    return parseInt(result.rows[0].count, 10);
};

// =============================================================================
// EXPORTS
// =============================================================================
module.exports = {
    getSchedules,
    create,
    update,
    remove,
    countByGid,
    // Export helpers for testing
    transformRowToSchedule,
    transformRowsToSchedules,
};
