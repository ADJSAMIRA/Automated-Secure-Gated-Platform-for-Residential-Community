const VisitorModel = require('../models/visitorModel');
const AdminModel = require('../models/adminModel'); 
const NotificationModel = require('../models/notificationModel'); 
const crypto = require('crypto');

exports.registerGuest = async (req, res) => {
    const { apartment_id, guest_name, guest_phone, visit_date, visit_time, duration, needs_parking } = req.body;

    try {
        let assignedSpotId = null;
        let spotNumber = "None";

        if (needs_parking === true) {
            const spot = await VisitorModel.findAvailableParking();
            if (spot) {
                assignedSpotId = spot.id_spot;
                spotNumber = spot.spot_number;
                await VisitorModel.updateParkingStatus(assignedSpotId, true);
            } else {
                return res.status(400).json({ success: false, message: "Full capacity! No parking spots available." });
            }
        }

        const qrToken = crypto.randomBytes(16).toString('hex');

        await VisitorModel.createRequest({
            apartment_id, 
            guest_name, 
            guest_phone, 
            visit_date, 
            visit_time, 
            duration, 
            needs_parking, 
            spot_id: assignedSpotId, 
            qrToken: qrToken
        });

        try {
            const admin = await AdminModel.getAdminDetails();
            if (admin) {
                let parkingMessage = needs_parking ? `with Parking Spot: ${spotNumber}` : "without parking";
                await NotificationModel.create({
                    user_id: admin.id_user,
                    title: "New Guest Registered ",
                    message: `A new guest "${guest_name}" has been registered for a visit on ${visit_date} at ${visit_time} ${parkingMessage}.`,
                    type: "System"
                });
            }
        } catch (notifError) {
            console.error("Failed to send notification to admin:", notifError);
        }
        

        res.status(200).json({
            success: true,
            message: "Guest Registered Successfully",
            qrToken: qrToken,
            parkingSpot: spotNumber
        });

    } catch (error) {
        console.error("Backend Error:", error);
        res.status(500).json({ success: false, message: "Database Error: " + error.message });
    }
};

exports.getMyGuests = async (req, res) => {
    const { apartmentId } = req.params;
    try {
        const guests = await VisitorModel.getGuestsByApartment(apartmentId);
        res.status(200).json({ success: true, data: guests });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.adminGetAllGuests = async (req, res) => {
    try {
        const allRequests = await VisitorModel.getAllRequestsForAdmin();
        res.status(200).json({
            success: true,
            count: allRequests.length,
            data: allRequests
        });
    } catch (error) {
        console.error("Admin Fetch Error:", error);
        res.status(500).json({ success: false, message: "Error fetching guest list" });
    }
};