const db = require('../config/db');

class VisitorModel {
    static async findAvailableParking() {
        const [rows] = await db.execute(
            'SELECT id_spot, spot_number FROM GuestParking WHERE is_occupied = FALSE LIMIT 1'
        );
        return rows[0];
    }

    static async updateParkingStatus(spotId, isOccupied) {
        return await db.execute(
            'UPDATE GuestParking SET is_occupied = ? WHERE id_spot = ?',
            [isOccupied, spotId]
        );
    }

    static async createRequest(data) {
        const sql = `INSERT INTO VisitorRequest 
            (apartment_id, guest_name, guest_phone, requestTime, visit_time, duration_hours, needs_parking, spot_id, qr_code_token, status) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Accepted')`;
        
        const params = [
            data.apartment_id, 
            data.guest_name, 
            data.guest_phone, 
            data.visit_date,   
            data.visit_time, 
            data.duration, 
            data.needs_parking ? 1 : 0, 
            data.spot_id, 
            data.qrToken
        ];
        
        return await db.execute(sql, params);
    }

    static async getGuestsByApartment(apartmentId) {
        const sql = `
            SELECT vr.*, gp.spot_number 
            FROM VisitorRequest vr
            LEFT JOIN GuestParking gp ON vr.spot_id = gp.id_spot
            WHERE vr.apartment_id = ?
            ORDER BY vr.id_request DESC`;
        const [rows] = await db.execute(sql, [apartmentId]);
        return rows;
    }
    static async getAllRequestsForAdmin() {
    const sql = `
        SELECT 
            vr.id_request,
            vr.guest_name,
            vr.guest_phone,
            vr.requestTime AS visit_date,
            vr.visit_time,
            vr.duration_hours,
            vr.status,
            vr.qr_code_token,
            gp.spot_number,
            u.fullName AS resident_name,
            a.doorNumber AS apartment_number,
            a.blockNumber
        FROM VisitorRequest vr
        LEFT JOIN GuestParking gp ON vr.spot_id = gp.id_spot
        LEFT JOIN Apartment a ON vr.apartment_id = a.id_apartment
        LEFT JOIN Resident r ON a.doorNumber = r.apartmentNumber
        LEFT JOIN \User\ u ON r.id_user = u.id_user
        ORDER BY vr.id_request DESC
    `;
    const [rows] = await db.execute(sql);
    return rows;
}

}

module.exports = VisitorModel;