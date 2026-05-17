const db = require('../config/db');

class MaintenanceStaffModel {
    static async getProfile(staffId) {
        const sql = `
            SELECT id_user, fullName, email, phoneNumber, job_type, qrCodeData, status 
            FROM \`User\` 
            WHERE id_user = ? AND role = 'MaintenanceStaff'
        `;
        const [rows] = await db.execute(sql, [staffId]);
        return rows[0];
    }

    static async getMyTasks(staffId) {
        const sql = `
            SELECT 
                t.id_Task, t.assignedDate, t.status AS task_status, t.staffRemarks,
                a.id_Alert, a.title, a.description, a.category, a.urgencyLevel,
                u.fullName AS resident_name, r.apartmentNumber
            FROM Task t
            JOIN Alert a ON t.alert_id = a.id_Alert
            JOIN \`User\` u ON a.reportedBy_id = u.id_user
            LEFT JOIN Resident r ON u.id_user = r.id_user
            WHERE t.staff_id = ?
            ORDER BY FIELD(t.status, 'pending', 'in progress', 'completed', 'canceled'), t.assignedDate DESC
        `;
        const [rows] = await db.execute(sql, [staffId]);
        return rows;
    }

    static async updateTask(taskId, status, remarks) {
        await db.execute(
            'UPDATE Task SET status = ?, staffRemarks = ? WHERE id_Task = ?',
            [status, remarks || null, taskId]
        );

        const [task] = await db.execute('SELECT alert_id FROM Task WHERE id_Task = ?', [taskId]);
        if (task.length > 0) {
            await db.execute('UPDATE Alert SET status = ? WHERE id_Alert = ?', [status, task[0].alert_id]);
        }
        return true;
    }
}

module.exports = MaintenanceStaffModel;