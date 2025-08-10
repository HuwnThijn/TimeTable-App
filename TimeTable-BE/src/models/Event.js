const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
    
    timetableId: { type: mongoose.Schema.Types.ObjectId, ref: 'TimeTable', required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

    title: { type: String, required: true },
    description: { type: String },
    location: { type: String },

    startTime: { type: Date, required: true },
    endTime: { type: Date, required: true },

    repeat: {
        type: {
            type: String, // 'none', 'daily', 'weekly'
            default: 'none'
        },
        daysOfWeek: { type: [Number]}, // 0-6 for Sunday-Saturday and only applicable if repeat.type is 'weekly'
        until: Date // the date until which the event repeats 
    },

    notifyBeforeMinutes: { type: Number, default: 30 }, // Notification time before the event starts

}, {timestamps: true});

module.exports = mongoose.model('Event', eventSchema);