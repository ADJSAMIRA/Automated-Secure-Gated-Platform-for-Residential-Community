const IotModel = require('../models/iotModel');
const db = require('../config/db');

let isNightMode = false;
let currentLightStatus = "OFF";
let gateStatus = "CLOSED";
let timer = null;

exports.getLightingState = (req, res) => res.json({ nightMode: isNightMode, lightStatus: currentLightStatus });
exports.toggleNightMode = (req, res) => { isNightMode = req.body.nightMode; res.json({ success: true }); };
exports.updateLightStatus = (req, res) => { currentLightStatus = req.body.status; res.json({ success: true }); };

exports.verifyQR = async (req, res) => {
    const userId = req.params.id;
    try {
        const user = await IotModel.getUserById(userId);

        if (!user || user.status !== 'Active') {
            gateStatus = "DENIED";
            return res.json({ success: false, status: "DENIED" });
        }

        gateStatus = "OPEN";
        await IotModel.logAccess(user.id_user, user.fullName, 'Granted');

        if (timer) clearTimeout(timer);
        timer = setTimeout(() => { gateStatus = "CLOSED"; }, 5000); 

        return res.json({ success: true, status: "OPEN" });
    } catch (error) { res.status(500).json({ error: error.message }); }
};

exports.getDoorStatus = (req, res) => {
    res.json({ status: gateStatus });
    if (gateStatus === "DENIED") gateStatus = "CLOSED";
};

exports.receiveFireAlert = async (req, res) => {
    try {
        const { device_id, category, urgency } = req.body; 
        const alertData = {
            title: "IoT FIRE ALERT",
            description: `Emergency: Fire detected by IoT Device ID: ${device_id || 1}`,
            category: category || "Fire", 
            source: "IoT System",
            reportedBy_id: null,
            device_id: device_id || 1, 
            urgencyLevel: urgency || "Critical"
        };
        await IotModel.createAlert(alertData);
        res.status(201).json({ success: true });
    } catch (error) { res.status(500).json({ error: error.message }); }
};

exports.updateParkingStatus = async (req, res) => {
    try {
        const { spot_name, status } = req.body; 
        const query = "UPDATE Parking SET status = ? WHERE spot_name = ?";
        await db.query(query, [status, spot_name]);
        res.json({ success: true });
    } catch (error) { res.status(500).json({ error: error.message }); }
};

exports.getAllParkingSpots = async (req, res) => {
    try {
        const spots = await IotModel.getAllParkingSpots();
        res.json({ success: true, spots: spots });
    } catch (error) { res.status(500).json({ error: error.message }); }
};