const mongoose = require('mongoose');

const OtpVerificationSchema = new mongoose.Schema({
    email : {type: String, required: true},
    otp: {type: String, required: true},
    expiresAt: {type: Date, required: true},
});

module.exports = mongoose.model('OtpVerification', OtpVerificationSchema);