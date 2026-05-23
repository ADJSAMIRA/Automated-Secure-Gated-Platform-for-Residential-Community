const db = require('../config/db');

class SecurityStaffModel {
    static async getProfile(staffId) {
        const sql = `
            SELECT id_user, fullName, email, phoneNumber, role, qrCodeData, status 
            FROM \`User\` 
            WHERE id_user = ? AND role = 'SecurityStaff'
        `;
        const [rows] = await db.execute(sql, [staffId]);
        return rows[0];
    }

    static async getMyTasks(staffId) {
        const sql = `
            SELECT 
                t.id_Task, 
                t.status AS task_status, 
                t.assignedDate,
                a.id_Alert, 
                a.title, 
                a.description, 
                a.urgencyLevel, 
                u.fullName AS reportedBy
            FROM Task t
            JOIN Alert a ON t.alert_id = a.id_Alert
            JOIN \`User\` u ON a.reportedBy_id = u.id_user
            WHERE t.staff_id = ?
            ORDER BY t.assignedDate DESC
        `;
        const [rows] = await db.execute(sql, [staffId]);
        return rows;
    }

    static async updateTask(taskId, status, remarks) {
        const taskSql = `
            UPDATE Task 
            SET status = ?, staffRemarks = ? 
            WHERE id_Task = ?
        `;
        await db.execute(taskSql, [status, remarks || null, taskId]);

        const [taskData] = await db.execute(`
            SELECT t.alert_id, a.reportedBy_id, a.title 
            FROM Task t 
            JOIN Alert a ON t.alert_id = a.id_Alert 
            WHERE t.id_Task = ?
        `, [taskId]);

        if (taskData.length > 0) {
            const { alert_id, reportedBy_id, title } = taskData[0];

            const alertUpdateSql = 'UPDATE Alert SET status = ? WHERE id_Alert = ?';
            await db.execute(alertUpdateSql, [status, alert_id]);

            return { residentId: reportedBy_id, alertTitle: title };
        }

        return null;
    }

    static async getSecurityTasks(staffId) {
        const sql = `
            SELECT t.*, a.title, a.urgencyLevel
            FROM Task t
            JOIN Alert a ON t.alert_id = a.id_Alert
            WHERE t.staff_id = ? AND a.category = 'Security'
        `;
        const [rows] = await db.execute(sql, [staffId]);
        return rows;
    }

    static async getDashboardStats(staffId) {
        const [alertsCount] = await db.execute(
            'SELECT COUNT(*) as count FROM Task WHERE staff_id = ? AND status IN ("pending", "in progress")',
            [staffId]
        );

        const [logsCount] = await db.execute(
            'SELECT COUNT(*) as count FROM Accesslog WHERE DATE(timestamp) = CURRENT_DATE'
        );

        return {
            alertsCount: alertsCount[0].count,
            logsCount: logsCount[0].count
        };
    }

    static async getAccessLogsByDate(filterType) {
        let dateCondition = '';
        
        if (filterType === 'today') {
            dateCondition = 'WHERE DATE(a.timestamp) = CURRENT_DATE';
        } else if (filterType === 'history') {
            dateCondition = 'WHERE DATE(a.timestamp) < CURRENT_DATE';
        }

        const sql = `
            SELECT 
                a.id_log, 
                a.user_id, 
                u.fullName AS user_name, 
                a.action, 
                a.timestamp,
                'Main Gate Scanner' AS device_name 
            FROM Accesslog a
            JOIN \`User\` u ON a.user_id = u.id_user
            ${dateCondition}
            ORDER BY a.timestamp DESC
        `;
        
        const [rows] = await db.execute(sql);
        return rows;
    }
}

module.exports = SecurityStaffModel;