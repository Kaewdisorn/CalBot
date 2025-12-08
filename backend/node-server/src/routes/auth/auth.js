const express = require('express');
const router = express.Router();

const authController = require('./../../controllers/auth.js');


router.post('/register', authController.register);
router.post('/login', //loginValidation, 
    authController.login);

module.exports = router;