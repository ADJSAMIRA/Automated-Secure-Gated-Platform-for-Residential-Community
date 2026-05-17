const express = require('express');
const router = express.Router();
const visitorController = require('../controllers/visitorController');

router.post('/register', visitorController.registerGuest);
router.get('/my-guests/:apartmentId', visitorController.getMyGuests);
router.get('/admin/all-guests', visitorController.adminGetAllGuests);
module.exports = router;