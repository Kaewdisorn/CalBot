/**
 * User Model
 * Represents a user entity with validation and transformation methods
 */
class User {
    /**
     * Create a User instance
     * @param {Object} params - User parameters
     * @param {string} params.gid - Group UUID
     * @param {string} params.uid - User UUID
     * @param {string} params.token - JWT token
     * @param {string} params.email - User email
     * @param {string} params.password - User password (hashed)
     * @param {Date|string} params.createdAt - Creation timestamp
     * @param {Date|string} params.updatedAt - Last update timestamp
     * 
     */
    constructor({ gid, uid, token, email, password, createdAt, updatedAt }) {
        this.gid = gid;
        this.uid = uid;
        this.token = token;
        this.email = email;
        this.password = password;
        this.createdAt = createdAt instanceof Date ? createdAt : new Date(createdAt);
        this.updatedAt = updatedAt instanceof Date ? updatedAt : new Date(updatedAt);
    }

    /**
     * Create User instance from database row
     * @param {Object} row - Database row with gid, uid, properties, created_at, updated_at
     * @returns {User|null} User instance or null if row is invalid
     */
    static fromDatabase(row) {
        if (!row) return null;

        const { gid, uid, properties, created_at, updated_at } = row;

        return new User({
            gid: gid,
            uid: uid,
            token: '',
            email: properties.email,
            password: properties.password,
            createdAt: created_at,
            updatedAt: updated_at
        });
    }

    // /**
    //  * Create User instance from API input
    //  * @param {Object} data - API request data
    //  * @param {string} data.gid - Group UUID
    //  * @param {string} data.uid - User UUID
    //  * @param {string} data.email - User email
    //  * @param {string} data.password - User password
    //  * @param {Date|string} [data.createdAt] - Creation timestamp (optional)
    //  * @param {Date|string} [data.updatedAt] - Last update timestamp (optional)
    //  * @returns {User} User instance
    //  */
    // static fromApiInput(data) {
    //     return new User({
    //         gid: data.gid,
    //         uid: data.uid,
    //         email: data.email,
    //         password: data.password,
    //         createdAt: data.createdAt || new Date(),
    //         updatedAt: data.updatedAt || new Date()
    //     });
    // }

    // /**
    //  * Validate user data
    //  * @returns {Object} Validation result with isValid and errors array
    //  */
    // validate() {
    //     const errors = [];

    //     // Email validation
    //     if (!this.email || typeof this.email !== 'string') {
    //         errors.push('Email is required');
    //     } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.email)) {
    //         errors.push('Invalid email format');
    //     }

    //     // Password validation
    //     if (!this.password || typeof this.password !== 'string') {
    //         errors.push('Password is required');
    //     }

    //     // UUID validation
    //     if (!this.gid || !this.uid) {
    //         errors.push('User IDs (gid, uid) are required');
    //     }

    //     return {
    //         isValid: errors.length === 0,
    //         errors
    //     };
    // }

    /**
     * Convert to JSON for API response (without password)
     * @returns {Object} User data without password
     */
    toJSON() {
        return {
            uid: this.uid,
            gid: this.gid,
            token: this.token,
            email: this.email,
            createdAt: this.createdAt,
            updatedAt: this.updatedAt
        };
    }

    // /**
    //  * Convert to JSON with password (for internal use only)
    //  * @returns {Object} Full user data including password
    //  */
    // toJSONWithPassword() {
    //     return {
    //         uid: this.uid,
    //         gid: this.gid,
    //         email: this.email,
    //         password: this.password,
    //         createdAt: this.createdAt,
    //         updatedAt: this.updatedAt
    //     };
    // }

    // /**
    //  * Prepare data for database insertion/update
    //  * @returns {Object} Database-ready data with properties JSONB
    //  */
    // toDatabase() {
    //     return {
    //         gid: this.gid,
    //         uid: this.uid,
    //         properties: {
    //             email: this.email,
    //             password: this.password
    //         }
    //     };
    // }

    // /**
    //  * Get user email in lowercase
    //  * @returns {string} Lowercase email
    //  */
    // getEmailLowercase() {
    //     return this.email ? this.email.toLowerCase() : '';
    // }
}

module.exports = User;
