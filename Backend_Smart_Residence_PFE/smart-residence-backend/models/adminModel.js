const db = require('../config/db');

class AdminModel {
    // USER DATA QUERIES
    
    static async getPendingUsers() {
        const sql = `
            SELECT u.id_user, u.fullName, u.email, u.phoneNumber, u.role, u.status, u.created_at,
                   r.apartmentNumber, a.blockNumber, a.floor
            FROM \`User\` u
            LEFT JOIN Resident r ON u.id_user = r.id_user
            LEFT JOIN Apartment a ON r.apartmentNumber = a.doorNumber
            WHERE u.status = 'pending'
            ORDER BY u.created_at DESC`;
        const [rows] = await db.execute(sql);
        return rows;
    }

    static async getActiveUsers() {
        const sql = `
            SELECT u.id_user, u.fullName, u.email, u.phoneNumber, u.role, u.status,
                   r.apartmentNumber, a.blockNumber
            FROM \`User\` u
            LEFT JOIN Resident r ON u.id_user = r.id_user
            LEFT JOIN Apartment a ON r.apartmentNumber = a.doorNumber
            WHERE u.status = 'Active'
            ORDER BY u.fullName ASC`;
        const [rows] = await db.execute(sql);
        return rows;
    }

    static async updateStatus(userId, status) {
        return db.execute('UPDATE `User` SET status = ? WHERE id_user = ?', [status, userId]);
    }

    static async updateQRCode(userId, qrData) {
        return db.execute('UPDATE `User` SET qrCodeData = ? WHERE id_user = ?', [qrData, userId]);
    }

    static async deleteUser(userId) {
    return db.execute('UPDATE `User` SET status = ? WHERE id_user = ?', ['Inactive', userId]);
}

static async getStats() {
    const [totalResidents] = await db.execute(
        'SELECT COUNT(*) as count FROM User WHERE role = "Resident" AND status = "Active"'
    );

    const [pendingApprovals] = await db.execute(
        'SELECT COUNT(*) as count FROM User WHERE status = "pending"'
    );

    const [activeEvents] = await db.execute(
        'SELECT COUNT(*) as count FROM Event WHERE status = "pending"'
    );

    const [activeAlerts] = await db.execute(
        'SELECT COUNT(*) as count FROM Alert WHERE status IN ("pending", "in progress")'
    );

    return {
        totalResidents: totalResidents[0].count,     
        pendingApprovals: pendingApprovals[0].count, 
        activeEvents: activeEvents[0].count,         
        activeAlerts: activeAlerts[0].count          
    };
}
    static async updateUserInfo(userId, data) {
        const { fullName, email } = data;
        
        await db.execute(
            "UPDATE `User` SET fullName = ?, email = ? WHERE id_user = ?", 
            [fullName, email, userId]
        );
    }
static async getActiveResidents() {
        const sql = `
            SELECT u.id_user, u.fullName, u.email, u.phoneNumber, u.status, u.created_at,
                   r.apartmentNumber, a.blockNumber, a.floor
            FROM \`User\` u
            JOIN Resident r ON u.id_user = r.id_user
            LEFT JOIN Apartment a ON r.apartmentNumber = a.doorNumber
            WHERE u.status = 'Active' AND u.role = 'Resident'
            ORDER BY u.fullName ASC
        `;
        const [rows] = await db.execute(sql);
        return rows;
    }
    // EVENT 
   
    static async getPendingEvents() {
        const sql = `
            SELECT 
                e.id_Event, 
                e.title, 
                e.description, 
                e.eventDate, 
                e.time, 
                e.endTime, 
                e.isPublic, 
                e.status, 
                u.fullName as organizerName, 
                u.role as organizerRole
            FROM Event e
            JOIN \`User\` u ON e.organizer_id = u.id_user
            WHERE e.status = 'pending'
            ORDER BY e.created_at DESC`;
        
        const [rows] = await db.execute(sql);
        return rows;
    }
    static async updateEventStatus(eventId, status) {
        return db.execute('UPDATE Event SET status = ? WHERE id_Event = ?', [status, eventId]);
    }

    static async getEventById(eventId) {
        const [rows] = await db.execute('SELECT * FROM Event WHERE id_Event = ?', [eventId]);
        return rows[0];
    }

    static async checkApprovedEvent(eventDate, startTime, endTime) {
        const sql = `
            SELECT * FROM Event 
            WHERE eventDate = ? AND status = 'Approved'
            AND time < ? AND endTime > ?
        `;
        const [rows] = await db.execute(sql, [eventDate, endTime, startTime]);
        return rows.length > 0; 
    }

   static async rejectPendingConflicts(eventDate, startTime, endTime, excludeEventId = null) {
        let sql = `UPDATE Event SET status = 'Rejected' 
                   WHERE eventDate = ? AND status = 'pending' AND time < ? AND endTime > ?`;
        let params = [eventDate, endTime, startTime];

        if (excludeEventId) {
            sql += ` AND id_Event != ?`;
            params.push(excludeEventId);
        }
        return db.execute(sql, params);
    }
    
 static async createAdminEvent(data) {
        const { title, description, eventDate, time, endTime, organizer_id } = data;

        const sql = `
            INSERT INTO Event (title, description, eventDate, time, endTime, isPublic, organizer_id, status) 
            VALUES (?, ?, ?, ?, ?, 1, ?, 'Approved')
        `;

        try {
            const [result] = await db.execute(sql, [
                title, 
                description || '',
                eventDate, 
                time, 
                endTime,
                organizer_id
            ]);
            return result; 
        } catch (error) {
            console.error("Database Error in createAdminEvent:", error.message);
            throw error; 
        }
    }

static async updateAdminEvent(eventId, data) {
        const { title, description, eventDate, time, endTime } = data;
        const sql = `UPDATE Event SET title=?, description=?, eventDate=?, time=?, endTime=? WHERE id_Event=?`;
        return db.execute(sql, [title, description, eventDate, time, endTime, eventId]);
    }

    static async deleteAdminEvent(eventId) {
        return db.execute(`DELETE FROM Event WHERE id_Event = ?`, [eventId]);
    }

    
static async getAdminCreatedEvents() {
    const sql = `
        SELECT e.*, u.fullName as organizer_name
        FROM Event e
        JOIN \`User\` u ON e.organizer_id = u.id_user
        WHERE u.role = 'Admin'
        ORDER BY e.eventDate DESC, e.time ASC
    `;
    const [rows] = await db.execute(sql);
    return rows;
}
static async getApprovedEvents() {
        const sql = `
            SELECT e.*, u.fullName as organizer_name, u.role as organizer_role
            FROM Event e
            JOIN \`User\` u ON e.organizer_id = u.id_user
            WHERE e.status = 'Approved'
            ORDER BY e.eventDate ASC, e.time ASC`;
        const [rows] = await db.execute(sql);
        return rows;
    }
    // ALERTS AND TASKS 
    
    static async getAllAlerts() {
        const sql = `
            SELECT a.id_Alert, a.title, a.description, a.category, a.source, 
                   a.urgencyLevel, a.status, a.timeStamp,
                   u.fullName as reporterName,
                   t.staff_id, s.fullName as assignedStaffName
            FROM Alert a
            LEFT JOIN \`User\` u ON a.reportedBy_id = u.id_user
            LEFT JOIN Task t ON a.id_Alert = t.alert_id
            LEFT JOIN \`User\` s ON t.staff_id = s.id_user
            ORDER BY a.timeStamp DESC
        `;
        const [rows] = await db.execute(sql);
        return rows;
    }

    static async updateAlertStatus(alertId, status) {
        return db.execute('UPDATE Alert SET status = ? WHERE id_Alert = ?', [status, alertId]);
    }

    static async getStaffList() {
        const sql = `
            SELECT id_user, fullName, role, job_type 
            FROM \`User\` 
            WHERE role IN ('SecurityStaff', 'MaintenanceStaff') AND status = 'Active'
        `;
        const [rows] = await db.execute(sql);
        return rows;
    }
   
    static async assignAlertToStaff(alertId, staffId) {
        const taskSql = `
            INSERT INTO Task (alert_id, staff_id, assignedDate, status) 
            VALUES (?, ?, NOW(), 'pending')
        `;
        await db.execute(taskSql, [alertId, staffId]);

        const alertSql = `UPDATE Alert SET status = 'in progress' WHERE id_Alert = ?`;
        await db.execute(alertSql, [alertId]);

        return true;
    }
    static async getAdminDetails() {
    const sql = `SELECT id_user, fullName, email FROM User WHERE role = 'Admin' LIMIT 1`;
    const [rows] = await db.execute(sql);
    return rows[0];
}

}

module.exports = AdminModel;