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
        ON CONFLICT (gid, uid) DO UPDATE SET
            gid = EXCLUDED.gid,
            properties = EXCLUDED.properties,
            updated_at = CURRENT_TIMESTAMP
        RETURNING gid, uid, properties, created_at, updated_at
    `;

    const result = await query(sql, [gid, uid, JSON.stringify(properties)]);
    return transformRowToUser(result.rows[0]);
};

const checkUserExists = async (email) => {
    const emailLower = email.toLowerCase();
    var sql = `SELECT ${SCHEMA}.uuid_generate_v5(${SCHEMA}.uuid_ns_url(), $1) AS uid`;
    const userUid = await query(sql, [emailLower]).then(res => res.rows[0]);

    sql = `SELECT gid, uid, properties, created_at, updated_at
    FROM ${FULL_TABLE} WHERE gid = $1 AND uid = $1`;

    const result = await query(sql, [userUid.uid]);

    if (result.rows.length > 0) {
        return { "isExists": true, "userUid": userUid.uid };
    } else {
        return { "isExists": false, "userUid": userUid.uid };
    }
}

// const getUserByEmail = async (email) => {
//     var sql = `SELECT ${SCHEMA}.uuid_generate_v5(${SCHEMA}.uuid_ns_url(), $1) AS uid`;
//     const userUid = await query(sql, [email.toLowerCase()]).then(res => res.rows[0]);

//     sql = `SELECT gid, uid, properties, created_at, updated_at
//     FROM ${FULL_TABLE} WHERE gid = $1 AND uid = $1`;

//     const result = await query(sql, [userUid.uid]);
//     return result.rows.length > 0 ? transformRowToUser(result.rows[0]) : null;

// };

const getUsers = async (uid) => {

    if (uid != null) {
        // Get specific user by uid
        const sql = `
        SELECT gid, uid, properties, created_at, updated_at
        FROM ${FULL_TABLE}
        WHERE uid = $1
    `;
        const result = await query(sql, [uid]);
        return result.rows.length > 0 ? transformRowToUser(result.rows[0]) : null;
    } else {
        // Get all users
        const sql = `
        SELECT gid, uid, properties, created_at, updated_at
        FROM ${FULL_TABLE}
        ORDER BY created_at ASC
    `;
        const result = await query(sql);
        return result.rows.map(transformRowToUser);
    }
}

module.exports = {
    upsertUser,
    getUsers,
    checkUserExists,
};
