const SecurityStaffModel = require('../models/securityStaffModel');
const NotificationModel = require('../models/notificationModel');
exports.getSecurityHome = async (req, res) => {
    try {
        const info = await SecurityStaffModel.getProfile(req.params.id);
        if (!info) return res.status(404).json({ success: false, message: "Security staff not found" });
        
        res.json({ success: true, data: info });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
exports.getSecurityTasks = async (req, res) => {
    try {
        const tasks = await SecurityStaffModel.getMyTasks(req.params.id);
        res.json({ success: true, data: tasks });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.updateSecurityTask = async (req, res) => {
    const { taskId } = req.params;
    const { status, remarks } = req.body; 

    try {
        await SecurityStaffModel.updateTask(taskId, status, remarks);

        
        const [taskData] = await db.execute(`
            SELECT a.reportedBy_id, a.title 
            FROM Task t 
            JOIN Alert a ON t.alert_id = a.id_Alert 
            WHERE t.id_Task = ?
        `, [taskId]);

        if (taskData.length > 0) {
            const residentId = taskData[0].reportedBy_id;
            const alertTitle = taskData[0].title;

            await NotificationModel.create({
                user_id: residentId, 
                title: "Alert Status Updated ",
                message: `The status of your alert "${alertTitle}" has been updated to "${status}" by the security staff.`,
                type: "Alert"
            });
        }

        res.json({ success: true, message: "Security task updated successfully!" });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
exports.getSecurityStats = async (req, res) => {
    try {
        const stats = await SecurityStaffModel.getDashboardStats(req.params.id);
        res.json({ success: true, data: stats });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
exports.getAccessLogs = async (req, res) => {
    const { filter } = req.query; 
    
    try {
        const logs = await SecurityStaffModel.getAccessLogsByDate(filter || 'today');
        res.json({ success: true, data: logs });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
