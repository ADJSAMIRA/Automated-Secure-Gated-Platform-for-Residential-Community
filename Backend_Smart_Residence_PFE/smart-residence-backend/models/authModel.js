const db = require('../config/db');

class AuthModel {
    static async findByEmail(email) {
        const [rows] = await db.execute('SELECT * FROM `User` WHERE email = ?', [email]);
        return rows[0];
    }

    static async createUser(userData) {
        const { fullName, email, password, phoneNumber, role, status, security_question, securityAnswer } = userData;
        const sql = `INSERT INTO \`User\` 
            (fullName, email, password, phoneNumber, role, status, security_question, securityAnswer) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;
        const [result] = await db.execute(sql, [fullName, email, password, phoneNumber, role, status, security_question, securityAnswer]);
        return result.insertId;
    }

    static async linkToSubTable(userId, role, extraData = {}) {
        switch (role) {
            case 'Resident':
                await db.execute('INSERT INTO Resident (id_user, apartmentNumber) VALUES (?, ?)', 
                    [userId, extraData.apartmentNumber || null]);
                break;
            case 'Admin': await db.execute('INSERT INTO Admin (id_user) VALUES (?)', [userId]); break;
            case 'MaintenanceStaff': await db.execute('INSERT INTO MaintenanceStaff (id_user) VALUES (?)', [userId]); break;
            case 'SecurityStaff': await db.execute('INSERT INTO SecurityStaff (id_user) VALUES (?)', [userId]); break;
        }
    }

    static async checkApartmentExists(doorNumber) {
        const [rows] = await db.execute('SELECT * FROM Apartment WHERE doorNumber = ?', [doorNumber]);
        return rows.length > 0;
    }

    static async countAdmins() {
        const [rows] = await db.execute('SELECT COUNT(*) as count FROM `User` WHERE role = "Admin"');
        return rows[0].count;
    }
    static async updateJobType(userId, jobType) {
        return db.execute('UPDATE `User` SET job_type = ? WHERE id_user = ?', [jobType, userId]);
    }
}

module.exports = AuthModel;