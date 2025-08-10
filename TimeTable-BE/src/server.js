require('dotenv').config();
const mongoose = require('mongoose');
const app = require('./app');

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/NoticeApp';

console.log('Starting server...');
console.log('MongoDB URI:', MONGO_URI);

mongoose.connect(MONGO_URI)
    .then(() => {
        console.log('Connected to MongoDB');
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
        });
    })
    .catch((err) => {
        console.error("Error connecting to MongoDB:", err);
        process.exit(1); // Exit the process if can't connect to DB
    });
