const db = require('../config/db');

class ChatModel {
    static async getOrCreateConversation(user1, user2) {
        const checkSql = `
            SELECT id_conversation FROM Conversation 
            WHERE (participant1_Id = ? AND participant2_Id = ?) 
               OR (participant1_Id = ? AND participant2_Id = ?)
        `;
        const [rows] = await db.execute(checkSql, [user1, user2, user2, user1]);
        if (rows.length > 0) return rows[0].id_conversation; 
        
        const insertSql = `INSERT INTO Conversation (participant1_Id, participant2_Id, lastUpdate) VALUES (?, ?, NOW())`;
        const [result] = await db.execute(insertSql, [user1, user2]);
        return result.insertId;
    }

    static async saveMessage(conversationId, senderId, receiverId, content) {
        const sql = `INSERT INTO Message (conversation_id, sender_id, receiver_id, content) VALUES (?, ?, ?, ?)`;
        await db.execute(sql, [conversationId, senderId, receiverId, content]);
        
        await db.execute(
            `UPDATE Conversation SET lastMessage = ?, lastUpdate = NOW() WHERE id_conversation = ?`, 
            [content, conversationId]
        );
    }

    static async getMessages(conversationId) {
        const sql = `SELECT * FROM Message WHERE conversation_id = ? ORDER BY timestamp ASC`;
        const [rows] = await db.execute(sql, [conversationId]);
        return rows;
    }

    static async getUserInbox(userId) {
        const sql = `
            SELECT c.id_conversation, c.lastMessage, c.lastUpdate,
            CASE WHEN c.participant1_Id = ? THEN u2.id_user ELSE u1.id_user END as contact_id,
            CASE WHEN c.participant1_Id = ? THEN u2.fullName ELSE u1.fullName END as contact_name,
            CASE WHEN c.participant1_Id = ? THEN u2.role ELSE u1.role END as contact_role
            FROM Conversation c
            JOIN \`User\` u1 ON c.participant1_Id = u1.id_user
            JOIN \`User\` u2 ON c.participant2_Id = u2.id_user
            WHERE c.participant1_Id = ? OR c.participant2_Id = ?
            ORDER BY c.lastUpdate DESC`;
        const [inbox] = await db.execute(sql, [userId, userId, userId, userId, userId]);
        return inbox;
    }

    static async deleteMessageById(messageId) {
        return await db.execute("DELETE FROM Message WHERE id_message = ?", [messageId]);
    }

    static async markAsRead(conversationId, senderId) {
        const sql = `UPDATE Message SET is_read = TRUE WHERE conversation_id = ? AND sender_id = ? AND is_read = FALSE`;
        return await db.execute(sql, [conversationId, senderId]);
    }

    static async updateMessageContent(messageId, newContent) {
        const sql = `UPDATE Message SET content = ?, is_edited = TRUE WHERE id_message = ?`;
        const [result] = await db.execute(sql, [newContent, messageId]);
        return result;
    }

    static async getSenderName(senderId) {
        const sql = `SELECT fullName FROM \`User\` WHERE id_user = ?`;
        const [rows] = await db.execute(sql, [senderId]);
        return rows.length > 0 ? rows[0].fullName : "Someone";
    }
}

module.exports = ChatModel;