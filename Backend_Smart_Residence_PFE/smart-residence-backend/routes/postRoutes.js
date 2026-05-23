const express = require('express');
const router = express.Router();
const postController = require('../controllers/postController');

router.get('/feed', postController.getCommunityFeed);
router.post('/posts', postController.createNewPost);
router.get('/posts/:postId/comments', postController.getPostComments);
router.post('/posts/:postId/comments', postController.addPostComment);
router.post('/posts/:postId/like', postController.likePostToggle);

module.exports = router;