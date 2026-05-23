//db.js
const mysql = require('mysql2');


const pool = mysql.createPool({
    host: 'localhost',       
    user: 'root',            
    password: '',           
    database: 'smart_residence', 
    waitForConnections: true,
    connectionLimit: 10, 
    queueLimit: 0
});


const db = pool.promise();


db.getConnection()
    .then(connection => {
        console.log(' MySQL Database Connected Successfully!');
        connection.release();
    })
    .catch(err => {
        console.error(' Database Connection Error:');
        console.error('Message:', err.message);
        console.error('Code:', err.code);
    });

module.exports = db;