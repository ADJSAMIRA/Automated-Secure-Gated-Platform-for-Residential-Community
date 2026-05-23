//middlewares/validateInput.js
const { body, validationResult } = require('express-validator');

const handleValidationErrors = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array().map(err => err.msg) });
    }
    next();
};

exports.validateSignup = [
    body("fullName").trim().notEmpty().withMessage("Full name is required"),
    body("email").trim().isEmail().withMessage("Invalid email format"),
    body("password").isLength({ min: 8 }).withMessage("Password too short"),

    body("role").optional().isIn(['Resident', 'Admin', 'SecurityStaff', 'MaintenanceStaff']),

    body("apartmentNumber")
        .if((value, { req }) => req.body.role === 'Resident')
        .notEmpty().withMessage("Apartment number is required for Resident"),

    body("security_question")
        .notEmpty().withMessage("Security question is required"),

    body("securityAnswer")
        .trim().notEmpty().withMessage("Security answer is required"),

    handleValidationErrors
];

exports.validateLogin = [
    body("email").trim().notEmpty().withMessage("Email is required"),
    body("password").notEmpty().withMessage("Password is required"),
    handleValidationErrors
];