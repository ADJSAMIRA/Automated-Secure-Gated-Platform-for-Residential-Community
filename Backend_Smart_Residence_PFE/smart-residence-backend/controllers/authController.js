const bcrypt = require('bcrypt');
const db = require('../config/db');

const jwt = require('jsonwebtoken');
const AuthModel = require('../models/authModel'); 
const AdminModel = require('../models/adminModel');
const NotificationModel = require('../models/notificationModel');
const JWT_SECRET = 'SmartResidence_Secret_2024_Key';

exports.signup = async (req, res) => {
    try {
        let { fullName, email, password, phoneNumber, 
              security_question, securityAnswer, apartmentNumber, role } = req.body;

        if (!role) role = 'Resident';

        if (role === 'Resident') {
            const apartmentExists = await AuthModel.checkApartmentExists(apartmentNumber); 
            if (!apartmentExists) {
                return res.status(400).json({ 
                    success: false, 
                    message: "The apartment number provided does not exist in our residence records." 
                });
            }
        }

        const existingUser = await AuthModel.findByEmail(email);
        if (existingUser) return res.status(400).json({ message: "Email already registered" });

        const hashedPassword = await bcrypt.hash(password, 10);
        let status = 'pending';
        if (role === 'Admin') {
            const adminCount = await AuthModel.countAdmins(); 
            status = (adminCount === 0) ? 'Active' : 'pending';
        }

        const userId = await AuthModel.createUser({ 
            fullName, email, password: hashedPassword, phoneNumber, 
            role, status, security_question, securityAnswer 
        });

        await AuthModel.linkToSubTable(userId, role, { apartmentNumber }); 

        try {
            const [admins] = await db.execute('SELECT id_user FROM `User` WHERE role = "Admin" AND status = "Active" LIMIT 1');
            
            const adminId = (admins && admins.length > 0) ? admins[0].id_user : null;

            if (adminId) {
                await NotificationModel.create({
                    user_id: adminId,
                    title: " New Account Approval Request",
                    message: `A new ${role} named "${fullName}" has signed up and is waiting for your approval.`,
                    type: "System" 
                });
                console.log(` Registration notification sent to Admin (ID: ${adminId})`);
            }
        } catch (notifError) {
            console.error(" Could not send signup notification to Admin:", notifError.message);
        }
         

        res.status(201).json({ success: true, message: "User registered successfully", status });

    } catch (error) {
        console.error("Signup Error:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await AuthModel.findByEmail(email); 

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

        await AuthModel.updateJobType(userId, job_type); 
        res.json({ success: true, message: "Job type updated successfully!" });
    } catch (error) {
        console.error("Error updating job type:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getSecurityQuestion = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) return res.status(400).json({ success: false, message: "Email is required" });

        const user = await AuthModel.findByEmail(email); 
        if (!user) return res.status(404).json({ success: false, message: "User not found" });

        res.json({ 
            success: true, 
            security_question: user.security_question 
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.resetPasswordWithQuestion = async (req, res) => {
    try {
        const { email, securityAnswer, newPassword } = req.body;

        if (!email || !securityAnswer || !newPassword) {
            return res.status(400).json({ success: false, message: "All fields are required" });
        }

        const user = await AuthModel.verifySecurityAnswer(email, securityAnswer);
        
        if (!user) {
            return res.status(400).json({ success: false, message: "Incorrect security answer or user not found" });
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        await AuthModel.updatePassword(email, hashedPassword);

        res.json({ success: true, message: "Password has been reset successfully!" });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};