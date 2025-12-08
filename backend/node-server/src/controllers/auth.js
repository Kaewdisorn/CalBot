const authRepository = require("../repositories/auth");
const { apiRes } = require("../utils/response");
const argon2 = require('argon2');

const register = async (req, res) => {

    try {
        const { email, password } = req.body || {};

        if (!email || !password) {
            return apiRes(res, 400, 'Email and password are required', null);
        }

        const existingUsers = await authRepository.getUserByEmail(email);

        if (existingUsers) {
            return apiRes(res, 400, 'User already exists with email', null);
        }

        const hashedPassword = await argon2.hash(password, {
            type: argon2.argon2id,
            memoryCost: 32768, // 32 MiB
            timeCost: 4,
            parallelism: 1
        });

        console.log('Hashed password for', email, ':', hashedPassword);
        const isMatch = await argon2.verify(hashedPassword, '123456');
        console.log('Password verification for "123456":', isMatch);


        return apiRes(res, 201, 'User registered successfully', { email });
    } catch (error) {
        console.error('Error in register:', error);
        return apiRes(res, 500, 'Internal server error :' + error.message, null);
    }
};
const login = async (req, res) => { };

module.exports = { register, login };