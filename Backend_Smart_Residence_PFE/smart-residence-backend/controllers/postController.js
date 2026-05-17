const PostModel = require('../models/postModel');

exports.getCommunityFeed = async (req, res) => {
    try {
        const feed = await PostModel.getAllFeed();
        res.status(200).json({ success: true, data: feed });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.createNewPost = async (req, res) => {
    const { author_id, content, postType } = req.body;
    if (!author_id || !content) {
        return res.status(400).json({ success: false, message: "Author ID and content are required" });
    }
    try {
        const postId = await PostModel.create(author_id, content, postType);
        res.status(201).json({ success: true, message: "Post created successfully", postId });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getPostComments = async (req, res) => {
    const { postId } = req.params;
    try {
        const comments = await PostModel.getCommentsByPostId(postId);
        res.status(200).json({ success: true, data: comments });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.addPostComment = async (req, res) => {
    const { postId } = req.params;
    const { author_id, text } = req.body;
    if (!author_id || !text) {
        return res.status(400).json({ success: false, message: "Author ID and text are required" });
    }
    try {
        const commentId = await PostModel.addComment(postId, author_id, text);
        res.status(201).json({ success: true, message: "Comment added successfully", commentId });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.likePostToggle = async (req, res) => {
    const { postId } = req.params;
    const { id_user } = req.body;
    if (!id_user) {
        return res.status(400).json({ success: false, message: "User ID is required" });
    }
    try {
        const result = await PostModel.toggleLike(postId, id_user);
        res.status(200).json({ success: true, action: result.action });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
