const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const User = require('../models/User');
const OtpVerification = require('../models/OtpVerification');
const sendEmail = require('../utils/sendEmail');

exports.register = async (req, res) => {
    try {
        const { name, email, password, timezone, role } = req.body;

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: 'Email already exists' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const newUser = new User({
            name,
            email,
            password: hashedPassword,
            timezone,
            role: role && role === 'admin' ? 'admin' : 'user'
        });

        const token = jwt.sign(
            {
                id: newUser._id,
                email: newUser.email,
                role: newUser.role
            },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        await newUser.save();

        res.status(201).json({
            message: 'User registered successfully',
            user: {
                id: newUser._id,
                name: newUser.name,
                email: newUser.email,
                timezone: newUser.timezone,
                role: newUser.role
            },
            token
        });
    } catch (error) {
        console.log('Register error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email });

        if (!user) {
            return res.status(400).json({ message: 'Invalid email or password' });
        }

        const isPasswordValid = await bcrypt.compare(password, user.password);

        if (!isPasswordValid) {
            return res.status(400).json({ message: 'Invalid email or password' });
        }

        const token = jwt.sign(
            {
                id: user._id,
                email: user.email,
                role: user.role
            },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.status(200).json({
            message: 'Login successfully',
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                timezone: user.timezone,
                role: user.role
            },
            token
        });
    } catch (error) {
        console.log('Login error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

exports.sendVerificationEmail = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ message: 'Email is required' });
        }

        const otp = crypto.randomInt(100000, 999999).toString();
        const expiresAt = new Date(Date.now() + 1.5 * 60 * 1000);

        console.log(`=== OTP GENERATED FOR ${email} ===`);
        console.log(`OTP: ${otp}`);
        console.log('================================');

        await OtpVerification.findOneAndUpdate(
            { email },
            { otp, expiresAt },
            { upsert: true, new: true }
        );

        const html = `
        <div style="max-width: 600px; margin: 0 auto; padding: 20px; font-family: Arial, sans-serif;">
            <div style="text-align: center; margin-bottom: 30px;">
                <h1 style="color: #2196F3; margin-bottom: 10px;">TimeTable App</h1>
                <h2 style="color: #333; margin-bottom: 20px;">Xác nhận email của bạn</h2>
            </div>
            
            <div style="background-color: #f5f5f5; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
                <p style="color: #333; font-size: 16px; margin-bottom: 15px;">Chào bạn,</p>
                <p style="color: #333; font-size: 16px; margin-bottom: 15px;">
                    Bạn đã yêu cầu tạo tài khoản trên TimeTable App. Vui lòng sử dụng mã OTP dưới đây để xác nhận email:
                </p>
                
                <div style="text-align: center; margin: 30px 0;">
                    <div style="background-color: #2196F3; color: white; font-size: 32px; font-weight: bold; padding: 15px 30px; border-radius: 8px; display: inline-block; letter-spacing: 8px;">
                        ${otp}
                    </div>
                </div>
                
                <p style="color: #666; font-size: 14px; text-align: center;">
                    Mã OTP này có hiệu lực trong <strong>90 giây</strong>
                </p>
            </div>
            
            <div style="border-top: 1px solid #eee; padding-top: 20px; color: #666; font-size: 12px;">
                <p>Nếu bạn không yêu cầu tạo tài khoản, vui lòng bỏ qua email này.</p>
                <p>Đây là email tự động, vui lòng không trả lời.</p>
            </div>
        </div>
        `;

        await sendEmail(email, 'Mã xác nhận TimeTable App - ' + otp, html);

        res.json({ message: 'OTP sent successfully' });
    } catch (error) {
        console.log('Send verification email error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

exports.verifyOtp = async (req, res) => {
    try {
        const { email, otp } = req.body;

        if (!email || !otp) {
            return res.status(400).json({ message: 'Email and OTP are required' });
        }

        const record = await OtpVerification.findOne({ email });

        if (!record) {
            return res.status(404).json({ message: 'No OTP found for this email' });
        }

        if (record.otp !== otp) {
            return res.status(400).json({ message: 'Invalid OTP' });
        }

        if (record.expiresAt < new Date()) {
            return res.status(400).json({ message: 'OTP has expired' });
        }

        await OtpVerification.deleteOne({ email });
        await User.updateOne(
            { email },
            { emailVerified: true }
        );

        res.json({ message: 'Email verified successfully' });
    } catch (error) {
        console.log('Verify OTP error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

exports.forgetPassword = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ message: 'Email is required' });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Generate new random 6-digit password
        const newPassword = crypto.randomInt(100000, 999999).toString();

        console.log(`=== NEW PASSWORD GENERATED FOR ${email} ===`);
        console.log(`New Password: ${newPassword}`);
        console.log('==========================================');

        // Hash and update password immediately
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        await User.updateOne(
            { email },
            { password: hashedPassword }
        );

        const html = `
        <div style="max-width: 600px; margin: 0 auto; padding: 20px; font-family: Arial, sans-serif;">
            <div style="text-align: center; margin-bottom: 30px;">
                <h1 style="color: #2196F3; margin-bottom: 10px;">TimeTable App</h1>
                <h2 style="color: #333; margin-bottom: 20px;">Mật khẩu mới của bạn</h2>
            </div>
            
            <div style="background-color: #f5f5f5; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
                <p style="color: #333; font-size: 16px; margin-bottom: 15px;">Chào bạn,</p>
                <p style="color: #333; font-size: 16px; margin-bottom: 15px;">
                    Bạn đã yêu cầu đặt lại mật khẩu. Mật khẩu mới của bạn là:
                </p>
                
                <div style="text-align: center; margin: 30px 0;">
                    <div style="background-color: #2196F3; color: white; font-size: 32px; font-weight: bold; padding: 15px 30px; border-radius: 8px; display: inline-block; letter-spacing: 8px;">
                        ${newPassword}
                    </div>
                </div>
                
                <p style="color: #666; font-size: 14px; text-align: center;">
                    Vui lòng đăng nhập bằng mật khẩu mới này
                </p>
                
                <p style="color: #FF5722; font-size: 14px; text-align: center; margin-top: 20px;">
                    <strong>Lưu ý:</strong> Bạn nên đổi mật khẩu sau khi đăng nhập thành công để bảo mật tài khoản.
                </p>
            </div>
            
            <div style="border-top: 1px solid #eee; padding-top: 20px; color: #666; font-size: 12px;">
                <p>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng liên hệ hỗ trợ ngay lập tức.</p>
                <p>Đây là email tự động, vui lòng không trả lời.</p>
            </div>
        </div>
        `;

        await sendEmail(email, 'Mật khẩu mới - TimeTable App', html);

        res.json({ 
            message: 'New password sent to your email successfully',
            info: 'Please check your email for the new password'
        });
    } catch (error) {
        console.log('Forget password error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};
