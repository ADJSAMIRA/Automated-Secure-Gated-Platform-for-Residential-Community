const express = require('express');
const router = express.Router();
const maintenanceController = require('../controllers/maintenanceStaffController');

router.get('/home/:id', maintenanceController.getMaintenanceHome);
router.get('/tasks/:id', maintenanceController.getMaintenanceTasks);
router.put('/tasks/:taskId/update', maintenanceController.updateMaintenanceTask);
module.exports = router;
