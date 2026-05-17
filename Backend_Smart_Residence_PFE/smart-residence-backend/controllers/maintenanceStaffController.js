const MaintenanceStaffModel = require('../models/maintenanceStaffModel');

exports.getMaintenanceHome = async (req, res) => {
    try {
        const info = await MaintenanceStaffModel.getProfile(req.params.id);
        if (!info) return res.status(404).json({ success: false, message: "Maintenance member not found" });
        res.json({ success: true, data: info });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getMaintenanceTasks = async (req, res) => {
    try {
        const tasks = await MaintenanceStaffModel.getMyTasks(req.params.id);
        res.json({ success: true, data: tasks });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.updateMaintenanceTask = async (req, res) => {
    const { taskId } = req.params;
    const { status, remarks } = req.body; 

    try {
        await MaintenanceStaffModel.updateTask(taskId, status, remarks);
        res.json({ success: true, message: "Maintenance task and Alert status updated!" });
    } catch (error) {
        console.error("Maintenance Update Error:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};