const mongoose = require('mongoose');

const timeTableSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true },
    description: { type: String },
    colorTheme: { type: String},
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
}, { timestamps: true });

module.exports = mongoose.model('TimeTable', timeTableSchema);