const express = require('express');
const router = express.Router();
const securityController = require('../controllers/securityStaffController');

router.get('/home/:id', securityController.getSecurityHome);
router.get('/tasks/:id', securityController.getSecurityTasks);
router.put('/tasks/:taskId/update', securityController.updateSecurityTask);
router.get('/stats/:id', securityController.getSecurityStats); 
router.get('/access-logs', securityController.getAccessLogs);
module.exports = router;