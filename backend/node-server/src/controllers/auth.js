const authRepository = require("../repositories/auth");
const { apiRes } = require("../utils/response");

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


        return apiRes(res, 201, 'User registered successfully', { email });
    } catch (error) {
        console.error('Error in register:', error);
        return apiRes(res, 500, 'Internal server error :' + error.message, null);
    }
};
const login = async (req, res) => { };

module.exports = { register, login };