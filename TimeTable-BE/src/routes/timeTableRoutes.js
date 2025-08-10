const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const { createTimeTable, getAllTimeTables, getTimeTableById, updateTimeTable, deleteTimeTable } = require('../controllers/timeTableController');

router.use(authMiddleware); // Apply auth middleware to all routes

router.post('/', createTimeTable);
router.get('/', getAllTimeTables);
router.get('/:id', getTimeTableById);
router.put('/:id', updateTimeTable);
router.delete('/:id', deleteTimeTable);

module.exports = router;