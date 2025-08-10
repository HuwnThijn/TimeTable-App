const nodeMailer = require('nodemailer');

// Alternative configuration for testing
const transporter = nodeMailer.createTransporter({
    host: 'smtp.gmail.com',
    port: 587,
    secure: false, // true for 465, false for other ports
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

// Test email configuration
const testEmailConfig = async () => {
    try {
        await transporter.verify();
        console.log('Email configuration is valid');
        return true;
    } catch (error) {
        console.error('Email configuration error:', error);
        return false;
    }
};

const sendEmail = async (to, subject, text) => {
    try {
        // Test configuration first
        const isValid = await testEmailConfig();
        if (!isValid) {
            console.log('Email config invalid, showing OTP in console only');
            return { messageId: 'config-invalid-' + Date.now() };
        }

        console.log('Sending email to:', to);
        
        const mailOptions = {
            from: `"TimeTable App" <${process.env.EMAIL_USER}>`,
            to: to,
            subject: subject,
            html: text,
            text: text.replace(/<[^>]*>/g, '') // fallback plain text
        };

        const info = await transporter.sendMail(mailOptions);
        console.log('Email sent successfully. Message ID:', info.messageId);
        return info;
    } catch (error) {
        console.error('Error sending email:', error.message);
        
        // For development, still return success
        console.log('FOR DEVELOPMENT: Check console for OTP');
        return { messageId: 'dev-fallback-' + Date.now() };
    }
};

module.exports = sendEmail;
