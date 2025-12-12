const authRepository = require("../repositories/auth");
const { apiRes } = require("../utils/response");
const argon2 = require('argon2');
const jwt = require('jsonwebtoken');

/**
 * Register a new user
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Promise<import('express').Response>} - API response
 */
const register = async (req, res) => {

    try {
        const { email, password } = req.body || {};

        if (!email || !password) {
            return apiRes(res, 400, 'Email and password are required', null);
        }

        const existingUsers = await authRepository.checkUserExists(email);

        if (existingUsers.isExists) {
            return apiRes(res, 400, 'User already exists with email', null);
        }

        const hashedPassword = await argon2.hash(password, {
            type: argon2.argon2id,
            memoryCost: 32768, // 32 MiB
            timeCost: 4,
            parallelism: 1
        });

        const userUid = existingUsers.userUid;
        const userGid = userUid;
        const properties = {
            email: email,
            password: hashedPassword
        };

        const userData = await authRepository.upsertUser(userGid, userUid, properties);

        console.log('Registered new user:', userData.email);

        const jwtSecret = process.env.JWT_SECRET;
        const expiresInSeconds = parseInt(process.env.JWT_EXPIRES_IN_SECONDS, 10);
        const token = jwt.sign(
            { userId: userData.uid, email: userData.email },
            jwtSecret,
            { expiresIn: expiresInSeconds }
        );

        userData.token = token;

        return apiRes(res, 201, 'User registered successfully', userData.toJSON());
    } catch (error) {
        console.error('Error in register:', error);
        return apiRes(res, 500, 'Internal server error :' + error.message, null);
    }
};
const login = async (req, res) => {
    try {
        const { email, password } = req.body || {};

        if (!email || !password) {
            return apiRes(res, 400, 'Email and password are required', null);
        }

        const existingUsers = await authRepository.checkUserExists(email);

        if (!existingUsers.isExists) {
            return apiRes(res, 401, 'Invalid credentials', null);
        }

        // Get user data
        const userData = await authRepository.getUsers(existingUsers.userUid);

        if (!userData) {
            return apiRes(res, 401, 'Invalid credentials', null);
        }

        // Verify password
        const passwordMatch = await argon2.verify(userData.password, password);

        if (!passwordMatch) {
            return apiRes(res, 401, 'Invalid credentials', null);
        }
        console.log('User logged in:', userData.email);

        // Generate JWT token
        const jwtSecret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
        const expiresInSeconds = parseInt(process.env.JWT_EXPIRES_IN_SECONDS, 10) || 604800; // 7 days
        const token = jwt.sign(
            { userId: userData.uid, email: userData.email },
            jwtSecret,
            { expiresIn: expiresInSeconds }
        );

        return apiRes(res, 200, 'Login successful', {
            token,
            user: userData.toJSON()
        });
    } catch (error) {
        console.error('Error in login:', error);
        return apiRes(res, 500, 'Internal server error: ' + error.message, null);
    }
};

module.exports = { register, login };