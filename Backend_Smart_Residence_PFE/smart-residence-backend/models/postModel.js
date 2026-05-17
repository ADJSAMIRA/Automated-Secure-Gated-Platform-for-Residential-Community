const db = require('../config/db'); 
const PostModel = {
    getAllFeed: async () => {
        const query = `
            SELECT 
                p.id_post, p.content, p.postType, p.timestamp,
                u.fullName AS authorName, u.role AS authorRole,
                (SELECT COUNT(*) FROM PostLikes WHERE id_post = p.id_post) AS likesCount,
                (SELECT COUNT(*) FROM Comment WHERE post_id = p.id_post) AS commentsCount
            FROM Post p
            JOIN User u ON p.author_id = u.id_user
            ORDER BY p.timestamp DESC;
        `;
        const [rows] = await db.execute(query);
        return rows;
    },

    create: async (author_id, content, postType) => {
        const query = `INSERT INTO Post (author_id, content, postType) VALUES (?, ?, ?)`;
        const [result] = await db.execute(query, [author_id, content, postType || 'Normal']);
        return result.insertId;
    },

    getCommentsByPostId: async (postId) => {
        const query = `
            SELECT c.id_comment, c.text, u.fullName AS commenterName, u.role AS commenterRole
            FROM Comment c
            JOIN User u ON c.author_id = u.id_user
            WHERE c.post_id = ?
            ORDER BY c.id_comment ASC;
        `;
        const [rows] = await db.execute(query, [postId]);
        return rows;
    },

    addComment: async (postId, authorId, text) => {
        const query = `INSERT INTO Comment (post_id, author_id, text) VALUES (?, ?, ?)`;
        const [result] = await db.execute(query, [postId, authorId, text]);
        return result.insertId;
    },

    toggleLike: async (postId, userId) => {
        const checkQuery = `SELECT * FROM PostLikes WHERE id_post = ? AND id_user = ?`;
        const [rows] = await db.execute(checkQuery, [postId, userId]);

        if (rows.length > 0) {
            const deleteQuery = `DELETE FROM PostLikes WHERE id_post = ? AND id_user = ?`;
            await db.execute(deleteQuery, [postId, userId]);
            return { action: 'unliked' };
        } else {
            const insertQuery = `INSERT INTO PostLikes (id_post, id_user) VALUES (?, ?)`;
            await db.execute(insertQuery, [postId, userId]);
            return { action: 'liked' };
        }
    }
};

module.exports = PostModel;