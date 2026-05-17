const db = require('../config/db');

class ResidentModel {
    // PROFILE AND STATS 
    static async getUserProfile(userId) {
        const sql = `
            SELECT u.fullName, r.apartmentNumber, a.blockNumber
            FROM \`User\` u
            LEFT JOIN Resident r ON u.id_user = r.id_user
            LEFT JOIN Apartment a ON r.apartmentNumber = a.doorNumber
            WHERE u.id_user = ?`;
        const [rows] = await db.execute(sql, [userId]);
        return rows[0];
    }

    static async getResidentStats(userId) {
        try {
            const [guests] = await db.execute(`
                SELECT COUNT(*) as count FROM VisitorRequest vr 
                JOIN Apartment a ON vr.apartment_id = a.id_apartment 
                JOIN Resident r ON a.doorNumber = r.apartmentNumber 
                WHERE r.id_user = ? AND vr.status = 'Accepted'`, [userId]);

            const [events] = await db.execute(`
                SELECT COUNT(DISTINCT e.id_Event) as count 
                FROM Event e
                LEFT JOIN EventAttendance ea ON e.id_Event = ea.id_Event
                WHERE e.eventDate >= CURDATE() AND e.status = 'Approved'
                AND (e.isPublic = 1 OR ea.id_user = ? OR e.organizer_id = ?)`, 
                [userId, userId]
            );

            const [alerts] = await db.execute(
                'SELECT COUNT(*) as count FROM Alert WHERE reportedBy_id = ? AND status = "pending"', 
                [userId]
            );

            const [messages] = await db.execute(`
                SELECT COUNT(*) as count FROM Message m 
                JOIN Conversation c ON m.conversation_id = c.id_conversation 
                WHERE (c.participant1_Id = ? OR c.participant2_Id = ?) 
                AND m.sender_id != ? 
                AND m.is_read = FALSE`, 
                [userId, userId, userId]
            );

            return {
                activeGuests: guests[0].count || 0,
                upcomingEvents: events[0].count || 0,
                pendingAlerts: alerts[0].count || 0,
                unreadMessages: messages[0].count || 0
            };
        } catch (error) {
            console.error("Stats Error:", error.message);
            return { activeGuests: 0, upcomingEvents: 0, pendingAlerts: 0, unreadMessages: 0 };
        }
    }

    // EVENT 
    static async createEvent(data) {
        const { title, description, eventDate, time, endTime, isPublic, organizer_id } = data;
        const sql = `INSERT INTO Event (title, description, eventDate, time, endTime, isPublic, organizer_id, status) 
                     VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')`;
        return db.execute(sql, [title, description, eventDate, time, endTime, isPublic, organizer_id]);
    }

    static async addInvites(eventId, userIds) {
        const sql = `INSERT INTO EventAttendance (id_user, id_Event, status) VALUES ?`;
        const values = userIds.map(userId => [userId, eventId, 'pending']);
        return db.query(sql, [values]);
    }

    static async getEventById(eventId) {
        const [rows] = await db.execute(`SELECT * FROM Event WHERE id_Event = ?`, [eventId]);
        return rows[0];
    }

    static async updateEvent(eventId, data) {
        const { title, description, eventDate, time, endTime, isPublic } = data;
        const sql = `UPDATE Event SET title=?, description=?, eventDate=?, time=?, endTime=?, isPublic=? WHERE id_Event=?`;
        return db.execute(sql, [title, description, eventDate, time, endTime, isPublic, eventId]);
    }

    static async deleteEvent(eventId) {
        return db.execute(`DELETE FROM Event WHERE id_Event = ?`, [eventId]);
    }

    static async getAllEvents(userId) {
        const sql = `
            SELECT 
                e.*, 
                u.fullName as organizer_name, 
                u.role as organizer_role 
            FROM Event e
            JOIN \`User\` u ON e.organizer_id = u.id_user
            LEFT JOIN EventAttendance ea ON e.id_Event = ea.id_Event
            WHERE 
                (u.role = 'Admin' AND e.status = 'Approved')
                OR e.organizer_id = ?                     
                OR (e.status = 'Approved' AND (e.isPublic = 1 OR ea.id_user = ?)) 
            GROUP BY e.id_Event  
            ORDER BY e.eventDate DESC`;
        
        const [rows] = await db.execute(sql, [userId, userId]);
        return rows; 
    }

    static async getEventParticipants(eventId) {
        const sql = `
            SELECT u.fullName, ea.status
            FROM EventAttendance ea
            JOIN \`User\` u ON ea.id_user = u.id_user
            WHERE ea.id_Event = ? AND ea.status IN ('Joined', 'Accepted')
        `;
        const [rows] = await db.execute(sql, [eventId]);
        return rows;
    }
       
    static async joinAnyEvent(eventId, userId, isPublic) {
        const countSql = `SELECT COUNT(*) as total FROM EventAttendance WHERE id_Event = ? AND status IN ('Joined', 'Accepted')`;
        const [[{ total }]] = await db.execute(countSql, [eventId]);
        
        if (total >= 50) {
            return { success: false, reason: 'full' };
        }

        const checkSql = `SELECT * FROM EventAttendance WHERE id_Event = ? AND id_user = ?`;
        const [existing] = await db.execute(checkSql, [eventId, userId]);
        
        if (existing.length > 0) {
            const currentStatus = existing[0].status;
            if (currentStatus === 'Joined' || currentStatus === 'Accepted') {
                return { success: false, reason: 'exists' }; 
            }
            if (currentStatus === 'pending') {
                await db.execute(`UPDATE EventAttendance SET status = 'Joined' WHERE id_Event = ? AND id_user = ?`, [eventId, userId]);
                return { success: true };
            }
        } else {
            if (!isPublic) {
                return { success: false, reason: 'not_invited' };
            } else {
                const sql = `INSERT INTO EventAttendance (id_user, id_Event, status) VALUES (?, ?, 'Joined')`;
                await db.execute(sql, [userId, eventId]);
                return { success: true };
            }
        }
    }

    // RESERVATIONS

    static async getBookedSpotsCount(space_id, reservationDate, startTime, endTime, excludeReservationId = null) {
        let sql = `
            SELECT COUNT(*) AS booked_spots 
            FROM Reservation 
            WHERE space_id = ? 
            AND reservationDate = ? 
            AND status = 'Approved'
            AND (startTime < ? AND ? < endTime)
        `;
        let params = [space_id, reservationDate, endTime, startTime];

        if (excludeReservationId) {
            sql += ` AND id_Reservation != ?`;
            params.push(excludeReservationId);
        }

        const [result] = await db.execute(sql, params);
        return result[0].booked_spots;
    }

    static async createReservation(space_id, userId, reservationDate, startTime, endTime) {
        const sql = `
            INSERT INTO Reservation (space_id, user_id, reservationDate, startTime, endTime, status) 
            VALUES (?, ?, ?, ?, ?, 'Approved')
        `;
        return db.execute(sql, [space_id, userId, reservationDate, startTime, endTime]);
    }

    static async getReservationById(reservationId) {
        const [rows] = await db.execute(`SELECT * FROM Reservation WHERE id_Reservation = ?`, [reservationId]);
        return rows.length > 0 ? rows[0] : null;
    }

    static async updateReservation(reservationId, space_id, reservationDate, startTime, endTime) {
        const sql = `
            UPDATE Reservation 
            SET space_id=?, reservationDate=?, startTime=?, endTime=?, status='Approved' 
            WHERE id_Reservation=?
        `;
        return db.execute(sql, [space_id, reservationDate, startTime, endTime, reservationId]);
    }
    
    static async deleteReservation(reservationId) {
        return db.execute(`DELETE FROM Reservation WHERE id_Reservation = ?`, [reservationId]);
    }

    static async getUpcomingReservations(userId) {
        const sql = `
            SELECT 
                r.id_Reservation, r.reservationDate, r.startTime, r.endTime, r.status,
                s.name AS space_name, s.category AS space_category
            FROM Reservation r
            JOIN SharedSpace s ON r.space_id = s.id_space
            WHERE r.user_id = ? AND r.reservationDate >= CURDATE()
            ORDER BY r.reservationDate ASC, r.startTime ASC
        `;
        const [rows] = await db.execute(sql, [userId]);
        return rows;
    }

    static async getSpaceDetails(space_id) {
        const [rows] = await db.execute(`SELECT name, capacity, openTime, closeTime FROM SharedSpace WHERE id_space = ?`, [space_id]);
        return rows.length > 0 ? rows[0] : null;
    }

    static async getSpaceBookingsByDate(space_id, date) {
        const sql = `
            SELECT startTime, endTime 
            FROM Reservation 
            WHERE space_id = ? AND reservationDate = ? AND status = 'Approved'
        `;
        const [rows] = await db.execute(sql, [space_id, date]);
        return rows;
    }

    static async getSharedSpaces() {
        const [rows] = await db.execute('SELECT * FROM SharedSpace WHERE isAvailable = 1');
        return rows;
    }

    // ALERTS 
    static async createAlert(alertData) {
        const { title, description, category, source, reportedBy_id, urgencyLevel } = alertData;
        const sql = `
            INSERT INTO Alert (title, description, category, source, reportedBy_id, urgencyLevel, status, timeStamp)
            VALUES (?, ?, ?, ?, ?, ?, 'pending', NOW())
        `;
        return db.execute(sql, [title, description, category, source, reportedBy_id, urgencyLevel]);
    }

    static async getResidentAlerts(userId) {
        const sql = `
            SELECT id_Alert, title, description, category, source, urgencyLevel, status, timeStamp 
            FROM Alert 
            WHERE reportedBy_id = ? 
            ORDER BY timeStamp DESC
        `;
        const [rows] = await db.execute(sql, [userId]);
        return rows;
    }

    static async getAllAlerts() {
        const sql = `
            SELECT 
                a.id_Alert, a.title, a.description, a.category, a.source, 
                a.urgencyLevel, a.status, a.timeStamp,
                u.fullName AS reportedBy_name, 
                r.apartmentNumber
            FROM Alert a
            JOIN \`User\` u ON a.reportedBy_id = u.id_user
            LEFT JOIN Resident r ON u.id_user = r.id_user
            ORDER BY 
                FIELD(a.status, 'pending', 'in progress', 'completed', 'canceled'), 
                a.timeStamp DESC
        `;
        const [rows] = await db.execute(sql);
        return rows;
    }

    static async updateAlertStatus(alertId, status) {
        return db.execute('UPDATE Alert SET status = ? WHERE id_Alert = ?', [status, alertId]);
    }

    static async getStaffList() {
        const sql = `
            SELECT id_user, fullName, role 
            FROM \`User\` 
            WHERE role IN ('MaintenanceStaff', 'SecurityStaff') 
            AND status = 'Active'
            ORDER BY role, fullName ASC
        `;
        const [rows] = await db.execute(sql);
        return rows;
    }

    static async searchByName(searchQuery) {
        const sql = `
            SELECT u.id_user, u.fullName, u.role, r.apartmentNumber 
            FROM \`User\` u
            LEFT JOIN Resident r ON u.id_user = r.id_user
            WHERE u.role = 'Resident' 
              AND u.status = 'Active' 
              AND u.fullName LIKE ?
        `;
        const [users] = await db.execute(sql, [`%${searchQuery}%`]);
        return users;
    }


    static async checkEventOverlap(eventDate, time, endTime, excludeEventId = null) {
        let sql = `
            SELECT * FROM Event 
            WHERE eventDate = ? AND status != 'Rejected' AND time < ? AND endTime > ?
        `;
        let params = [eventDate, endTime, time];

        if (excludeEventId) {
            sql += ` AND id_Event != ?`;
            params.push(excludeEventId);
        }

        const [rows] = await db.execute(sql, params);
        return rows.length > 0;
    }

    static async getActiveAdminId() {
        const [rows] = await db.execute(
            "SELECT id_user FROM `User` WHERE role = 'Admin' AND status = 'Active' LIMIT 1"
        );
        return rows.length > 0 ? rows[0].id_user : 1;
    }

    static async revertEventToPending(eventId) {
        return db.execute('UPDATE Event SET status = "pending" WHERE id_Event = ?', [eventId]);
    }
}

module.exports = ResidentModel;