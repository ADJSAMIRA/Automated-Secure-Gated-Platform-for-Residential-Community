const express = require('express');
const router = express.Router();
const NotificationModel = require('../models/notificationModel'); 

router.get('/by-user/:userId', async (req, res) => {
    try {
        const notifications = await NotificationModel.getByUserId(req.params.userId);
        res.json({ success: true, data: notifications });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

router.put('/mark-as-read/:id', async (req, res) => {
    try {
        await NotificationModel.markAsRead(req.params.id);
        res.json({ success: true, message: "Notification marked as read" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;