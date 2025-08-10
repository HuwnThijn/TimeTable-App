const e = require('express');
const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
    const authHeader = req.headers.authorization;

    //Check if the authorization header is present
    if(!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Authorization header is missing or invalid' });
    }

    const token = authHeader.split(' ')[1];

    try {

        // Giải mã token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;

        req.user = {
            id: decoded.id,
            email: decoded.email,
            role: decoded.role
        }

        next(); // Proceed to the next middleware or route handler  
    } catch (error) {
        console.error('Authentication error:', error);
        return res.status(401).json({ message: 'Invalid token' });
    }
};

module.exports = authMiddleware;