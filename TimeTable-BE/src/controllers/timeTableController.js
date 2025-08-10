const TimeTable = require('../models/Timetable');

//CREATE
exports.createTimeTable = async (req, res) => {
    try {

        const { title, description, colorTheme, startDate, endDate } = req.body;

        const newTimeTable = new TimeTable({
            userId: req.user.id,
            title,
            description,
            colorTheme,
            startDate,
            endDate
        });

        await newTimeTable.save();
        res.status(201).json({ message: 'Timetable created successfully', data: newTimeTable });

    } catch (error) {
        console.error('Error creating timetable:', error);
        res.status(500).json({ message: 'Internal server error' });

    }
};

//READ ALL
exports.getAllTimeTables = async (req, res) => {
    try {
        const timeTable = await TimeTable.find({ userId: req.user.id }).sort({ createdAt: -1 });
        res.json({ data: timeTable });

    } catch (error) {
        console.error('Error fetching timetables:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

//READ ONE
exports.getTimeTableById = async (req, res) => {
    try {

        const timeTable = await TimeTable.findOne({ _id: req.params.id, userId: req.user.id });

        if (timeTable) {
            res.json({ data: timeTable });
        } else {
            res.status(404).json({ message: 'Timetable not found' });
        }

    } catch (error) {
        console.error('Error fetching timetable:', error);
        res.status(500).json({ message: 'Internal server error' });

    }
};

//UPDATE
exports.updateTimeTable = async (req, res) => {
    try {

        const timeTable = await TimeTable.findOneAndUpdate(
            { _id: req.params.id, userId: req.user.id },
            req.body,
            { new: true }
        );

        if (!timeTable) {
            return res.status(404).json({ message: 'Timetable not found' });
        }

        res.json({ message: 'Timetable updated successfully', data: timeTable });

    } catch (error) {
        console.error('Error updating timetable:', error);
        res.status(500).json({ message: 'Internal server error' });

    }
};

//DELETE
exports.deleteTimeTable = async (req, res) => {
    try {

        const timeTable = await TimeTable.findOneAndDelete({ _id: req.params.id, userId: req.user.id });

        if (!timeTable) {
            return res.status(404).json({ message: 'Timetable not found' });
        }

        res.json({ message: 'Timetable deleted successfully' });
        
    } catch (error) {
        console.error('Error deleting timetable:', error);
        res.status(500).json({ message: 'Internal server error' });

    }
}