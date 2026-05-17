const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');

router.get('/inbox/:userId', chatController.getUserInbox);
router.get('/history/:user1/:user2', chatController.getChatHistory);
router.post('/send', chatController.sendMessage);
router.delete('/delete-message/:messageId', chatController.deleteMessage);
router.put('/edit-message/:messageId', chatController.editMessage);
module.exports = router;