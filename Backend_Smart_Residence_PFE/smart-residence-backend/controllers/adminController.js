const AdminModel = require('../models/adminModel'); 
const ResidentModel = require('../models/residentModel');
const NotificationModel = require('../models/notificationModel');
const db = require('../config/db');

const QRCode = require('qrcode');

// Approve a user, activate account, and generate a unique QR Code

exports.manageUserStatus = async (req, res) => {
    const { userId, status } = req.body;
    
    try {
        if (status.toLowerCase() === 'active') {
            await db.query('UPDATE User SET status = ? WHERE id_user = ?', ['Active', userId]);
            
            const qrDataUrl = `https://adjsamira.github.io/smartgate-pfe/`;
            const generatedQR = await QRCode.toDataURL(qrDataUrl);
            
            await db.query('UPDATE User SET qrCodeData = ? WHERE id_user = ?', [generatedQR, userId]);
            
            await NotificationModel.create({
                user_id: userId,
                title: "Account Activated! ",
                message: "Your registration request has been approved. Welcome to the app!",
                type: "System"
            });
            
            return res.json({ success: true, message: "User approved and activated!" });
        } 
        else if (status.toLowerCase() === 'rejected') {
            await db.query('DELETE FROM User WHERE id_user = ?', [userId]);
            return res.json({ success: true, message: "User rejected and permanently deleted." });
        }
        
        res.status(400).json({ success: false, message: "Invalid status provided" });
        
    } catch (error) {
        console.error("Error in manageUserStatus:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};
exports.updateUser = async (req, res) => {
    const userId = req.params.id;
    const { fullName, email } = req.body;
    
    try {
        await AdminModel.updateUserInfo(userId, { 
            fullName, 
            email 
        });
        res.json({ success: true, message: "User profile updated successfully" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
exports.deleteUser = async (req, res) => {
    const userId = req.params.id;
    try {
        await AdminModel.deleteUser(userId);
        res.json({ success: true, message: "User deactivated successfully" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
exports.getPendingUsers = async (req, res) => {
    try {
        const users = await AdminModel.getPendingUsers();
        res.json(users);
    } catch (error) {
        console.error(" Error in getPendingUsers:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};
exports.getDashboardStats = async (req, res) => {
    try {
        const stats = await AdminModel.getStats();
        res.json({ success: true, data: stats });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
exports.getActiveUsers = async (req, res) => {
    try {
        const users = await AdminModel.getActiveUsers(); 
        res.json(users);
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
exports.getActiveResidents = async (req, res) => {
    try {
        const residents = await AdminModel.getActiveResidents(); 
        res.json(residents); 
    } catch (error) {
        console.error("Error in getActiveResidents:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};
// EVENT MANAGEMENT 

exports.getPendingEvents = async (req, res) => {
    try {
        const events = await AdminModel.getPendingEvents();
        res.json(events);
    } catch (error) {
        console.error(" Error in getPendingEvents:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.manageEventStatus = async (req, res) => {
    const { eventId, status } = req.body; 
    
    try {
        if (!['Approved', 'Rejected', 'Deleted'].includes(status)) {
            return res.status(400).json({ success: false, message: "Invalid status" });
        }
        
        const eventToApprove = await AdminModel.getEventById(eventId);
        if (!eventToApprove) {
            return res.status(404).json({ success: false, message: "Event not found" });
        }

        if (status === 'Deleted') {
            await AdminModel.deleteAdminEvent(eventId);
            return res.json({ success: true, message: "Event deleted successfully!" });
        }

        if (status === 'Approved') {
            const isAlreadyBooked = await AdminModel.checkApprovedEvent(
                eventToApprove.eventDate, 
                eventToApprove.time, 
                eventToApprove.endTime
            );
            
            if (isAlreadyBooked) {
                return res.status(400).json({ 
                    success: false, 
                    message: "Approval failed! Another event is already approved during this time."
                });
            }

            await AdminModel.updateEventStatus(eventId, 'Approved');
            await AdminModel.rejectPendingConflicts(eventToApprove.eventDate, eventToApprove.time, eventToApprove.endTime, eventId);

            await NotificationModel.create({
                user_id: eventToApprove.organizer_id,
                title: "Event Request Approved! ",
                message: `Your event "${eventToApprove.title}" has been successfully approved.`,
                type: "Event"
            });

            return res.json({ success: true, message: "Event Approved successfully!" });
        }

        await AdminModel.updateEventStatus(eventId, 'Rejected');

        await NotificationModel.create({
            user_id: eventToApprove.organizer_id,
            title: "Event Request Rejected",
            message: `Your event request "${eventToApprove.title}" has been rejected.`,
            type: "Event"
        });

        res.json({ success: true, message: "Event Rejected successfully!" });

    } catch (error) {
        console.error("Error in manageEventStatus:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};
//  ADMIN EVENT CREATION

exports.createAdminEvent = async (req, res) => {
    try {
        const { title, description, eventDate, time, endTime, organizer_id } = req.body;

        const isAlreadyBooked = await AdminModel.checkApprovedEvent(eventDate, time, endTime);
        
        if (isAlreadyBooked) {
            return res.status(400).json({ 
                success: false, 
                message: "This date/time slot is unavailable. Please choose another." 
            });
        }

        const result = await AdminModel.createAdminEvent({ 
            title, description, eventDate, time, endTime, organizer_id 
        });

        await AdminModel.rejectPendingConflicts(eventDate, time, endTime);

        res.status(201).json({ 
            success: true, 
            message: "Admin Event created successfully!",
            eventId: result.insertId 
        });

    } catch (error) {
        console.error("Critical Error in createAdminEvent:", error);
        res.status(500).json({ 
            success: false, 
            message: "A database error occurred.", 
            error: error.message 
        });
    }
};
exports.getMyAdminEvents = async (req, res) => {
    try {
        const events = await AdminModel.getAdminCreatedEvents();
        res.json({ success: true, data: events });
    } catch (error) {
        console.error("Error in getMyAdminEvents:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};
exports.updateAdminEvent = async (req, res) => {
    const eventId = req.params.id;
    const { title, description, eventDate, time, endTime } = req.body;
    
    try {
        const oldEvent = await AdminModel.getEventById(eventId);
        const isTimeChanged = (oldEvent.eventDate !== eventDate || oldEvent.time !== time || oldEvent.endTime !== endTime);

        if (isTimeChanged) {
            const isAlreadyBooked = await AdminModel.checkApprovedEvent(eventDate, time, endTime);
            if (isAlreadyBooked) {
                return res.status(400).json({ success: false, message: "Time slot already taken!" });
            }
        }

        await AdminModel.updateAdminEvent(eventId, { title, description, eventDate, time, endTime });
        
        if (isTimeChanged) {
            await AdminModel.rejectPendingConflicts(eventDate, time, endTime, eventId);
        }

        res.json({ success: true, message: "Admin Event updated successfully!" });
    } catch (error) {
        console.error("Error in updateAdminEvent:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};
exports.deleteAdminEvent = async (req, res) => {
    const eventId = req.params.id;
    try {
        await AdminModel.deleteAdminEvent(eventId);
        res.json({ success: true, message: "Event deleted successfully!" });
    } catch (error) {
        console.error(" Error in deleteAdminEvent:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};
exports.getApprovedEvents = async (req, res) => {
    try {
        const events = await AdminModel.getApprovedEvents();
        res.json(events);
    } catch (error) {
        console.error(" Error in getApprovedEvents:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};
//  ALERTS AND TASKS MANAGEMENT

exports.getAllAlerts = async (req, res) => {
    try {
        const alerts = await AdminModel.getAllAlerts();
        res.json({ success: true, data: alerts });
    } catch (error) {
        console.error("Error fetching alerts:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.updateAlertStatus = async (req, res) => {
    const alertId = req.params.id;
    let { status } = req.body; 

    if (!status) {
        return res.status(400).json({ success: false, message: "Status is required." });
    }

    status = status.toLowerCase();

    const validStatuses = ['pending', 'in progress', 'completed', 'canceled'];
    if (!validStatuses.includes(status)) {
        return res.status(400).json({ success: false, message: "Invalid status value." });
    }

    try {
        await AdminModel.updateAlertStatus(alertId, status);
        res.json({ success: true, message: `Alert status updated to '${status}' successfully!` });
    } catch (error) {
        console.error("Error updating alert status:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

//  Get staff list
exports.getStaffList = async (req, res) => {
    try {
        const staff = await AdminModel.getStaffList();
        res.json({ success: true, data: staff });
    } catch (error) {
        console.error("Error fetching staff list:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.assignTaskToStaff = async (req, res) => {
    const alertId = req.params.alertId;
    const { staff_id } = req.body; 

    if (!staff_id) {
        return res.status(400).json({ success: false, message: "Please select a staff member." });
    }

    try {
        await AdminModel.assignAlertToStaff(alertId, staff_id);

        await NotificationModel.create({
            user_id: staff_id,
            title: "New Task Assigned! ",
            message: "You have been assigned to handle a maintenance/security alert. Please check your tasks list.",
            type: "Alert"
        });

        res.json({ 
            success: true, 
            message: "Task successfully assigned! Alert is now 'In Progress'." 
        });
    } catch (error) {
        console.error("Error assigning task:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};


exports.getAdminInfo = async (req, res) => {
    try {
        const admin = await AdminModel.getAdminDetails();
        if (admin) {
            res.json(admin);
        } else {
            res.status(404).json({ message: "Admin not found" });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
