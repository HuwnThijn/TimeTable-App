const express = require('express');
const router = express.Router();
const {register, login, sendVerificationEmail, verifyOtp, forgetPassword} = require('../controllers/authController');

router.post('/register', register);
router.post('/login', login);
router.post('/send-verification', sendVerificationEmail);
router.post('/verify-otp', verifyOtp);
router.post('/forget-password', forgetPassword);

module.exports = router;