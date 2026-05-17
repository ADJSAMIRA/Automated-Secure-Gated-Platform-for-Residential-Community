//routes/authRoutes.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { validateSignup, validateLogin } = require('../middlewares/validateInput');

router.post('/signup', validateSignup, authController.signup);
router.post('/login', validateLogin, authController.login);
router.put('/update-job-type/:id', authController.updateJobType);
module.exports = router;