/**
 * =============================================================================
 * PostgreSQL Database Configuration
 * =============================================================================
 * 
 * This module sets up the PostgreSQL connection pool using the `pg` library.
 * A connection pool is used instead of single connections for better performance
 * and resource management in production environments.
 * 
 * SETUP INSTRUCTIONS:
 * 1. Install the pg package: npm install pg
 * 2. Create a .env file in the node-server directory with your database credentials
 * 3. Import this module where you need database access
 * 
 * ENVIRONMENT VARIABLES (add to .env file):
 * -----------------------------------------
 * DB_HOST=localhost          # Database server hostname
 * DB_PORT=5432               # PostgreSQL port (default: 5432)
 * DB_NAME=calbot             # Database name
 * DB_USER=postgres           # Database username
 * DB_PASSWORD=your_password  # Database password
 * 
 * USAGE EXAMPLE:
 * --------------
 * const { pool, query } = require('./config/database');
 * 
 * // Using the query helper (recommended)
 * const result = await query('SELECT * FROM users WHERE id = $1', [userId]);
 * 
 * // Using the pool directly for transactions
 * const client = await pool.connect();
 * try {
 *   await client.query('BEGIN');
 *   await client.query('INSERT INTO users (name) VALUES ($1)', ['John']);
 *   await client.query('COMMIT');
 * } catch (e) {
 *   await client.query('ROLLBACK');
 *   throw e;
 * } finally {
 *   client.release();
 * }
 */

const { Pool } = require('pg');

// =============================================================================
// DATABASE CONFIGURATION
// Load connection settings from environment variables with fallback defaults
// =============================================================================
const dbConfig = {
    // Database host - where PostgreSQL is running
    host: process.env.DB_HOST || 'localhost',

    // PostgreSQL port (default is 5432)
    port: parseInt(process.env.DB_PORT) || 5432,

    // Database name to connect to
    database: process.env.DB_NAME || 'calbot',

    // Database user credentials
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'your_password_here',

    // ==========================================================================
    // CONNECTION POOL SETTINGS
    // These settings control how the pool manages database connections
    // ==========================================================================

    // Maximum number of clients in the pool
    // Increase for high-traffic applications
    max: parseInt(process.env.DB_POOL_MAX) || 20,

    // Minimum number of idle clients to keep in the pool
    min: parseInt(process.env.DB_POOL_MIN) || 2,

    // Close idle clients after this many milliseconds (30 seconds)
    idleTimeoutMillis: 30000,

    // Return an error if a client cannot be acquired within this time (10 seconds)
    connectionTimeoutMillis: 10000,
};

// =============================================================================
// CREATE CONNECTION POOL
// The pool manages multiple database connections efficiently
// =============================================================================
const pool = new Pool(dbConfig);

// =============================================================================
// POOL EVENT HANDLERS
// These help with debugging and monitoring the connection pool
// =============================================================================

// Log when a new client connects to the pool
pool.on('connect', (client) => {
    console.log('📦 New database client connected to pool');
});

// Log errors from idle clients in the pool
pool.on('error', (err, client) => {
    console.error('❌ Unexpected database pool error:', err.message);
});

// Log when a client is removed from the pool
pool.on('remove', (client) => {
    console.log('🔌 Database client removed from pool');
});

// =============================================================================
// QUERY HELPER FUNCTION
// A convenient wrapper for executing queries with automatic connection handling
// =============================================================================

/**
 * Execute a SQL query using a pooled connection
 * 
 * @param {string} text - SQL query string (use $1, $2, etc. for parameters)
 * @param {Array} [params=[]] - Array of parameter values (prevents SQL injection)
 * @returns {Promise<Object>} - Query result with rows, rowCount, etc.
 * 
 * @example
 * // Simple query
 * const users = await query('SELECT * FROM users');
 * 
 * // Parameterized query (ALWAYS use this for user input!)
 * const user = await query('SELECT * FROM users WHERE email = $1', [email]);
 * 
 * // Insert with returning
 * const newUser = await query(
 *   'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
 *   [name, email]
 * );
 */
const query = async (text, params = []) => {
    const start = Date.now();

    try {
        const result = await pool.query(text, params);
        const duration = Date.now() - start;

        // Log slow queries (over 100ms) for performance monitoring
        if (duration > 100) {
            console.log('🐢 Slow query:', { text, duration: `${duration}ms`, rows: result.rowCount });
        }

        return result;
    } catch (error) {
        console.error('❌ Database query error:', {
            query: text,
            error: error.message
        });
        throw error;
    }
};

// =============================================================================
// CONNECTION TEST FUNCTION
// Call this on server startup to verify database connectivity
// =============================================================================

/**
 * Test database connection
 * Call this function on server startup to verify the database is accessible
 * 
 * @returns {Promise<boolean>} - True if connection successful, throws on failure
 * 
 * @example
 * // In server.js
 * const { testConnection } = require('./config/database');
 * 
 * app.listen(port, async () => {
 *   await testConnection();
 *   console.log('Server started');
 * });
 */
const testConnection = async () => {
    try {
        const result = await query('SELECT NOW() as current_time, version() as pg_version');
        const { current_time, pg_version } = result.rows[0];

        console.log('✅ Database connected successfully!');
        console.log(`   📅 Server time: ${current_time}`);
        console.log(`   🐘 PostgreSQL: ${pg_version.split(',')[0]}`);

        return true;
    } catch (error) {
        console.error('❌ Database connection failed!');
        console.error(`   Error: ${error.message}`);
        console.error('   Please check your database credentials in .env file');
        throw error;
    }
};

// =============================================================================
// GRACEFUL SHUTDOWN
// Properly close all pool connections when the application shuts down
// =============================================================================

/**
 * Close all pool connections gracefully
 * Call this before shutting down the server
 * 
 * @example
 * process.on('SIGTERM', async () => {
 *   await closePool();
 *   process.exit(0);
 * });
 */
const closePool = async () => {
    console.log('🔌 Closing database pool...');
    await pool.end();
    console.log('✅ Database pool closed');
};

// Handle process termination signals
process.on('SIGINT', async () => {
    await closePool();
    process.exit(0);
});

process.on('SIGTERM', async () => {
    await closePool();
    process.exit(0);
});

// =============================================================================
// EXPORTS
// =============================================================================
module.exports = {
    pool,           // Raw pool for advanced usage (transactions, etc.)
    query,          // Helper function for simple queries
    testConnection, // Test database connectivity
    closePool,      // Graceful shutdown
};
