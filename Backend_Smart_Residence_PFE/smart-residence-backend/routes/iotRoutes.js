const express = require('express');
const router = express.Router();
const iotController = require('../controllers/iotController');

router.get('/lighting-state', iotController.getLightingState);
router.post('/night-mode', iotController.toggleNightMode);
router.post('/light-status', iotController.updateLightStatus);
router.get('/verify-qr/:id', iotController.verifyQR);
router.get('/door-status', iotController.getDoorStatus);
router.post('/fire-alert', iotController.receiveFireAlert);
router.post('/parking-update', iotController.updateParkingStatus);
router.get('/parking-spots', iotController.getAllParkingSpots);

module.exports = router;