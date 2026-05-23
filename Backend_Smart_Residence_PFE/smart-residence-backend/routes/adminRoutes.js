//routes/adminRoutes.js
const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
// ROUTES FOR USER MANAGEMENT
router.get('/pending', adminController.getPendingUsers);
router.get('/active', adminController.getActiveUsers);
router.get('/residents/active', adminController.getActiveResidents);
router.post('/activate', adminController.manageUserStatus);
router.put('/update/:id', adminController.updateUser);
router.delete('/delete/:id', adminController.deleteUser);
router.get('/stats', adminController.getDashboardStats);
// ROUTES FOR EVENT MANAGEMENT
router.get('/events/pending', adminController.getPendingEvents);
router.post('/events/manage', adminController.manageEventStatus);
router.post('/events/create', adminController.createAdminEvent);
router.put('/events/update/:id', adminController.updateAdminEvent);
router.delete('/events/delete/:id', adminController.deleteAdminEvent);
router.get('/events/approved', adminController.getApprovedEvents);
router.get('/events/my-events', adminController.getMyAdminEvents);
// ROUTES FOR ALERTS AND TASKS MANAGEMENT
router.get('/alerts', adminController.getAllAlerts);
router.put('/alerts/:id/status', adminController.updateAlertStatus);

router.get('/staff-list', adminController.getStaffList);
router.post('/alerts/:alertId/assign', adminController.assignTaskToStaff);
router.get('/admin-info', adminController.getAdminInfo);
module.exports = router;