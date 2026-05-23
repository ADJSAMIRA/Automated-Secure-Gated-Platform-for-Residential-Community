const express = require('express');
const router = express.Router();
const residentController = require('../controllers/residentController');
const NotificationModel = require('../models/notificationModel'); 
const db = require('../config/db'); 
router.get('/all-residents', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT id_user, fullName FROM `User` WHERE role = "Resident" AND status = "Active"');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// RESIDENT DASHBOARD And PROFILE
router.get('/profile/:id', residentController.getResidentProfile);
router.get('/stats/:id', residentController.getStats);
// EVENT MANAGEMENT
router.get('/events/approved', residentController.getUpcomingEvents);
router.get('/events', residentController.listEvents);
router.post('/events', residentController.createEvent);
router.put('/events/:id', residentController.updateEvent);
router.delete('/events/:id', residentController.deleteEvent);
// ATTENDANCE AND INVITATIONS
router.post('/events/join', residentController.joinEvent);
router.get('/events/:id/participants', residentController.getParticipants); 

// SHARED SPACES 
router.get('/shared-spaces', residentController.getSharedSpaces);

// RESERVATIONS 
router.post('/reservations', residentController.createReservation);
router.get('/reservations/upcoming/:userId', residentController.getUpcomingReservations);
router.put('/reservations/:id', residentController.updateReservation);
router.delete('/reservations/:id', residentController.deleteReservation);
router.get('/shared-spaces/:spaceId/availability', residentController.getSpaceAvailability);

router.post('/alerts', residentController.reportAlert);
router.get('/alerts/history/:userId', residentController.getResidentAlertsHistory);
router.get('/search', residentController.searchResidents);

module.exports = router;
