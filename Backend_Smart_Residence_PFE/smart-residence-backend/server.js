const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const adminRoutes = require('./routes/adminRoutes');
const residentRoutes = require('./routes/residentRoutes'); 
const iotRoutes = require('./routes/iotRoutes');
const chatRoutes = require('./routes/chatRoutes'); 
const visitorRoutes = require('./routes/visitorRoutes');
const maintenanceRoutes = require('./routes/maintenanceRoutes');
const securityRoutes = require('./routes/securityRoutes')
const notificationRoutes = require('./routes/notificationRoutes');
const socialRoutes = require('./routes/postRoutes'); 
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
    console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.originalUrl}`);
    if (req.method === 'POST' || req.method === 'PUT') {
        console.log('Body Data:', req.body);
    }
    next();
});

app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/resident', residentRoutes);
app.use('/api/iot', iotRoutes);
app.use('/api/chat', chatRoutes); 
app.use('/api/visitor', visitorRoutes);
app.use('/api/maintenance', maintenanceRoutes); 
app.use('/api/security', securityRoutes); 
app.use('/api/notifications', notificationRoutes);  
app.use('/api/social', socialRoutes);   
app.get('/', (_req, res) => {
    res.json({ 
        status: "success", 
        message: "Smart Residence API is running",
        timestamp: new Date()
    });
});

app.use((_req, res) => {
    res.status(404).json({ success: false, message: "Route not found" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(` Server started on port: ${PORT}`);
    console.log(`Local access: http://localhost:${PORT}`);
});

module.exports = app;