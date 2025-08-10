const Event = require('../models/Event');

//CREATE EVENT
exports.createEvent = async (req, res) => {
    try {

        const { title, description, location, startTime, timetableId, endTime, repeat, notifyBeforeMinutes } = req.body;

        const newEvent = new Event({
            userId: req.user.id, // Assuming user ID is available in req.user
            timetableId,
            title,
            description,
            location,
            startTime,
            endTime,
            repeat,
            notifyBeforeMinutes
        });

        await newEvent.save();
        res.status(201).json({
            message: 'Event created successfully',
            data: newEvent
        });

    } catch (error) {
        console.error('Error creating event:', error);
        res.status(500).json({ message: 'Internal server error' });

    }
};

//GET ALL EVENTS BY TIMETABLE ID
exports.getEvents = async (req, res) => {
    try {

        const { timetableId } = req.query;
        const query = { userId: req.user.id };

        if (timetableId) {
            query.timetableId = timetableId;
        }

        const events = await Event.find(query).sort({ startTime: 1 });
        res.json({
            data: events
        });

    } catch (error) {
        console.error('Error fetching events:', error);
        res.status(500).json({ message: 'Internal server error' });

    }
};

//GET EVENT BY ID
exports.getEventById = async (req, res) => {
    try {
        
        const event = await Event.fintOne({ _id: req.params.id, userId: req.user.id });

        if (!event) {
            return res.status(404).json({ message: 'Event not found' });
        }

        res.json({
            data: event
        });

    } catch (error) {
        console.error('Error fetching event:', error);
        res.status(500).json({ message: 'Internal server error' });
        
    }
};

//UPDATE EVENT
exports.updateEvent = async (req, res) => {
    try {
        
        const updateEvent = await Event.findOneAndUpdate(
            { _id: req.params.id, userId: req.user.id },
            req.body,
            { new: true }
        );

        if (!updateEvent) {
            return res.status(404).json({ message: 'Event not found' });
        }

        res.json({
            message: 'Event updated successfully',
            data: updateEvent
        });

    } catch (error) {
        console.error('Error updating event:', error);
        res.status(500).json({ message: 'Internal server error' });
        
    }
};

//DELETE EVENT
exports.deleteEvent = async (req, res ) => {
    try {
        
        const deleteEvent = await Event.findOneAndDelete({
            _id: req.params.id,
            userId: req.user.id
        })

        if (!deleteEvent) {
            return res.status(404).json({ message: 'Event not found' });
        }

        res.json({
            message: 'Event deleted successfully',
        });

    } catch (error) {
        console.error('Error deleting event:', error);
        res.status(500).json({ message: 'Internal server error' });
        
    }
}