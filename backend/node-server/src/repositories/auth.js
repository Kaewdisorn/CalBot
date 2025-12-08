const { query } = require('../config/database');

const SCHEMA = 'v1';
const TABLE = 'users';
const FULL_TABLE = `${SCHEMA}.${TABLE}`;

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/**
 * Transform database row to API response format
 * Extracts properties from JSONB and flattens the structure
 * 
 * @param {Object} row - Database row with gid, uid, properties, timestamps
 * @returns {Object} - Flattened user object for API response
 */
const transformRowToUser = (row) => {
    if (!row) return null;
    const { gid, uid, properties, created_at, updated_at } = row;

    return {
        gid,
        uid,
        ...properties,
        createdAt: created_at,
        updatedAt: updated_at,
    };
};

// =============================================================================
// REPOSITORY METHODS
// =============================================================================

/**
 * Upsert a user (insert or update if exists)
 * Uses PostgreSQL's ON CONFLICT to handle upsert in a single query
 * 
 * @param {string} gid - Group UUID
 * @param {string} uid - User UUID (primary key)
 * @param {Object} properties - User properties to store in JSONB
 * @returns {Promise<Object>} - Upserted user object
 * 
 * @example
 * const user = await upsertUser('group-uuid', 'user-uuid', {
 *   name: 'John Doe',
 *   email: 'john@example.com'
 * });
 */
const upsertUser = async (gid, uid, properties = {}) => {
    const sql = `
        INSERT INTO ${FULL_TABLE} (gid, uid, properties)
        VALUES ($1, $2, $3)
        ON CONFLICT (uid) DO UPDATE SET
            gid = EXCLUDED.gid,
            properties = EXCLUDED.properties,
            updated_at = CURRENT_TIMESTAMP
        RETURNING gid, uid, properties, created_at, updated_at
    `;

    const result = await query(sql, [gid, uid, JSON.stringify(properties)]);
    return transformRowToUser(result.rows[0]);
};

module.exports = {
    upsertUser,
};
