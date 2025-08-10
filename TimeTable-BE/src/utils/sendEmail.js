const nodeMailer = require('nodemailer');

const transporter = nodeMailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

const sendEmail = async (to, subject, text) => {
    try {
        console.log('📧 Sending email via Gmail...');
        console.log('From:', process.env.EMAIL_USER);
        console.log('To:', to);
        
        // Verify transporter configuration
        await transporter.verify();
        console.log('✅ Gmail SMTP connection verified');
        
        const mailOptions = {
            from: `"TimeTable App" <${process.env.EMAIL_USER}>`,
            to: to,
            subject: subject,
            html: text,
            text: text.replace(/<[^>]*>/g, '') // Plain text fallback
        };

        const info = await transporter.sendMail(mailOptions);
        console.log('✅ Email sent successfully via Gmail!');
        console.log('📧 Message ID:', info.messageId);
        console.log('📬 Email delivered to:', to);
        
        return info;
    } catch (error) {
        console.error('❌ Gmail sending error:', error.message);
        console.error('📧 Config check:');
        console.error('- User:', process.env.EMAIL_USER);
        console.error('- Pass length:', process.env.EMAIL_PASS ? process.env.EMAIL_PASS.length : 'Not set');
        
        // Re-throw error to handle in controller
        throw error;
    }
};

module.exports = sendEmail;