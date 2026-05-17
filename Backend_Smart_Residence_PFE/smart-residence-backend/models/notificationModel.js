const db = require('../config/db');

class NotificationModel {
    static async create({ user_id, title, message, type }) {
        const sql = `INSERT INTO Notification (user_id, title, message, type) VALUES (?, ?, ?, ?)`;
        return db.execute(sql, [user_id, title, message, type]);
    }

    static async getByUserId(userId) {
        const sql = `SELECT * FROM Notification WHERE user_id = ? ORDER BY created_at DESC`;
        const [rows] = await db.execute(sql, [userId]);
        return rows;
    }

    static async markAsRead(notificationId) {
        const sql = `UPDATE Notification SET is_read = TRUE WHERE id_notification = ?`;
        return db.execute(sql, [notificationId]);
    }
}

module.exports = NotificationModel;