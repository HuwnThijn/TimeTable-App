const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const timeTableRoutes = require('./routes/timeTableRoutes');
const eventRoutes = require('./routes/eventRoutes');

const app = express();

// Middleware setup should come before routes
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/auth/", authRoutes);
app.use("/api/timetables/", timeTableRoutes);
app.use("/api/events/", eventRoutes);

app.get('/', (req, res) => {
  res.send('Welcome to the Notice App API');
});

module.exports = app;
