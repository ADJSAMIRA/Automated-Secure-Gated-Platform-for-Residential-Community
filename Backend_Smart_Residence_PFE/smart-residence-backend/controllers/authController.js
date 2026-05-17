//controllers/authControllers.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/authModel');
const AdminModel = require('../models/adminModel');
const NotificationModel = require('../models/notificationModel');
const JWT_SECRET = 'SmartResidence_Secret_2024_Key';


exports.signup = async (req, res) => {
    try {
        let { fullName, email, password, phoneNumber, 
              security_question, securityAnswer, apartmentNumber, role } = req.body;

        if (!role) role = 'Resident';

        if (role === 'Resident') {
            const apartmentExists = await User.checkApartmentExists(apartmentNumber);
            if (!apartmentExists) {
                return res.status(400).json({ 
                    success: false, 
                    message: "The apartment number provided does not exist in our residence records." 
                });
            }
        }

        const existingUser = await User.findByEmail(email);
        if (existingUser) return res.status(400).json({ message: "Email already registered" });

        const hashedPassword = await bcrypt.hash(password, 10);
        let status = 'pending';
        if (role === 'Admin') {
            const adminCount = await User.countAdmins();
            status = (adminCount === 0) ? 'Active' : 'pending';
        }

        const userId = await User.createUser({
            fullName, email, password: hashedPassword, phoneNumber, 
            role, status, security_question, securityAnswer 
        });

        await User.linkToSubTable(userId, role, { apartmentNumber });

        res.status(201).json({ success: true, message: "User registered successfully", status });

    } catch (error) {
        console.error("Signup Error:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findByEmail(email);

        if (!user) return res.status(404).json({ message: "User not found" });

        if (user.status === 'pending') return res.status(403).json({ message: "Account pending approval" });
        
        if (user.status === 'Inactive') {
            return res.status(403).json({ message: "Account deactivated. Please contact administration." });
        }
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ message: "Invalid login credentials" });

        const token = jwt.sign(
            { id: user.id_user, role: user.role }, 
            JWT_SECRET, 
            { expiresIn: '24h' }
        );

        res.json({ 
            success: true, 
            token, 
            user: { 
                id: user.id_user, 
                fullName: user.fullName, 
                role: user.role,
                job_type: user.job_type 
            } 
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
exports.updateJobType = async (req, res) => {
    try {
        const userId = req.params.id;
        const { job_type } = req.body;

        if (!job_type) {
            return res.status(400).json({ success: false, message: "Job type is required" });
        }

        await User.updateJobType(userId, job_type);
        
        res.json({ success: true, message: "Job type updated successfully!" });
    } catch (error) {
        console.error("Error updating job type:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};