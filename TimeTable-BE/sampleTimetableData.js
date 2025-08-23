const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Timetable = require('./src/models/Timetable');
const User = require('./src/models/User');

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
    .then(() => {
        console.log('Connected to MongoDB');
        createSampleTimetables();
    })
    .catch((err) => {
        console.error('Error connecting to MongoDB:', err);
    });

const sampleTimetables = [
    {
        title: "Học kỳ 1 năm 2024-2025",
        description: "Thời khóa biểu học kỳ 1 chính thức",
        colorTheme: "#3b82f6", // Blue
        startDate: new Date('2024-09-01'),
        endDate: new Date('2024-12-31')
    },
    {
        title: "Học kỳ 2 năm 2024-2025",
        description: "Thời khóa biểu học kỳ 2 chính thức",
        colorTheme: "#10b981", // Green
        startDate: new Date('2025-01-15'),
        endDate: new Date('2025-05-30')
    },
    {
        title: "Kỳ học hè 2025",
        description: "Thời khóa biểu học kỳ hè",
        colorTheme: "#f59e0b", // Orange
        startDate: new Date('2025-06-01'),
        endDate: new Date('2025-08-15')
    },
    {
        title: "Lịch làm việc Q1/2025",
        description: "Thời khóa biểu công việc quý 1",
        colorTheme: "#8b5cf6", // Purple
        startDate: new Date('2025-01-01'),
        endDate: new Date('2025-03-31')
    },
    {
        title: "Lịch thi cuối kỳ",
        description: "Lịch thi cuối kỳ học kỳ 1",
        colorTheme: "#ef4444", // Red
        startDate: new Date('2024-12-15'),
        endDate: new Date('2024-12-30')
    },
    {
        title: "Khóa học tiếng Anh",
        description: "Lịch học tiếng Anh tại trung tâm",
        colorTheme: "#06b6d4", // Cyan
        startDate: new Date('2024-10-01'),
        endDate: new Date('2025-03-31')
    },
    {
        title: "Dự án thực tập",
        description: "Lịch thực tập tại công ty",
        colorTheme: "#84cc16", // Lime
        startDate: new Date('2025-02-01'),
        endDate: new Date('2025-05-31')
    },
    {
        title: "Lịch ôn tập tốt nghiệp",
        description: "Lịch ôn tập chuẩn bị tốt nghiệp",
        colorTheme: "#f97316", // Orange
        startDate: new Date('2025-03-01'),
        endDate: new Date('2025-06-30')
    }
];

async function createSampleTimetables() {
    try {
        // Find all users to assign timetables
        const users = await User.find();
        
        if (users.length === 0) {
            console.log('No users found. Please create some users first.');
            return;
        }

        // Clear existing timetables
        await Timetable.deleteMany({});
        console.log('Cleared existing timetables');

        // Create sample timetables for each user
        const timetablesToCreate = [];
        
        users.forEach((user, userIndex) => {
            // Each user gets 2-3 timetables
            const numTimetables = Math.floor(Math.random() * 2) + 2; // 2-3 timetables per user
            
            for (let i = 0; i < numTimetables; i++) {
                const sampleIndex = (userIndex * numTimetables + i) % sampleTimetables.length;
                const sample = sampleTimetables[sampleIndex];
                
                timetablesToCreate.push({
                    userId: user._id,
                    title: `${sample.title} - ${user.name}`,
                    description: sample.description,
                    colorTheme: sample.colorTheme,
                    startDate: sample.startDate,
                    endDate: sample.endDate
                });
            }
        });

        // Insert all timetables
        const createdTimetables = await Timetable.insertMany(timetablesToCreate);
        
        console.log(`Created ${createdTimetables.length} sample timetables successfully!`);
        console.log('\nSample timetables:');
        createdTimetables.forEach((timetable, index) => {
            console.log(`${index + 1}. ${timetable.title}`);
            console.log(`   Description: ${timetable.description}`);
            console.log(`   Duration: ${timetable.startDate.toDateString()} - ${timetable.endDate.toDateString()}`);
            console.log(`   Color: ${timetable.colorTheme}`);
            console.log(`   User ID: ${timetable.userId}`);
            console.log('');
        });

        mongoose.connection.close();
        console.log('Database connection closed.');
        
    } catch (error) {
        console.error('Error creating sample timetables:', error);
        mongoose.connection.close();
    }
}

// Export sample data for use in other files
module.exports = sampleTimetables;
