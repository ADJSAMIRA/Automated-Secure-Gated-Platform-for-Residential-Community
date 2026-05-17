const db = require('../config/db');

class IotModel {
    static async getUserById(userId) {
        const [rows] = await db.query('SELECT * FROM User WHERE id_user = ?', [userId]);
        return rows.length ? rows[0] : null;
    }

    static async logAccess(userId, userName, action) {
        await db.query('INSERT INTO Accesslog (user_id, user_name, action) VALUES (?, ?, ?)', [userId, userName, action]);
    }

    static async createAlert(data) {
        const query = `
            INSERT INTO Alert 
            (title, description, category, source, reportedBy_id, device_id, urgencyLevel, status, timeStamp) 
            VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', NOW())
        `;
        const [result] = await db.query(query, [
            data.title, data.description, data.category, 
            data.source, data.reportedBy_id, data.device_id, data.urgencyLevel
        ]);
        return result;
    }
    static async getAllParkingSpots() {
        const [rows] = await db.query('SELECT spot_name, status FROM Parking ORDER BY id_parking ASC');
        return rows;
    }
}
module.exports = IotModel;