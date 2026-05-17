# 🏢 Smart Residence Management System

## 🌟 Overview
The **Smart Residence Management System** is a comprehensive, IoT-integrated solution designed to modernize and secure residential complexes. It seamlessly connects hardware sensors, a robust backend server, a relational database, and cross-platform mobile applications to provide a smart, automated living experience for residents, administrators, and security staff.

## ✨ Key Features
* 🚪 **Smart Gate Access:** Secure entry system using personalized QR codes for residents and staff.
* 🔥 **Emergency Fire Detection:** Real-time flame monitoring that instantly triggers critical alerts to the system and admin dashboard.
* 🚗 **Smart Parking Management:** Ultrasonic sensors detect vehicle presence to update parking availability (Available/Occupied) in real-time.
* 💡 **Intelligent Lighting:** Automated street lighting based on night-mode configuration and motion/IR detection.
* 📱 **Cross-Platform Mobile Apps:** Dedicated Flutter applications for end-users (Residents) and management (Admins/Security).

## 🛠️ Technologies & Tools Used
* **IoT & Hardware:** ESP8266 (NodeMCU), Ultrasonic Sensor (HC-SR04), Flame Sensor, IR Sensor, I2C LCD Display, C++ (Arduino IDE/VS Code), Wokwi Simulator.
* **Backend:** Node.js, Express.js, RESTful APIs.
* **Database:** MySQL.
* **Mobile App (Frontend):** Flutter (Dart).
* **Web Services:** HTML/JS/CSS for Web QR Scanner, Cloudflare Tunnels (for secure localhost exposure).

## 📂 Repository Structure
This repository contains the full source code of the project, divided into the following modules:

* `1_IoT_Hardware/` : Contains the ESP8266 C++ code and Wokwi simulation configurations.
* `2_Web_QR_Scanner/` : Contains the HTML/JS web interface for the gate QR code verification.
* `3_Backend/` : Contains the Node.js API source code.
* `4_Database/` : Contains the `smart_residence.sql` file with the database schema and sample data.
* `5_Flutter_Apps/` : Contains the Flutter source code for the mobile applications.

## 👥 Meet the Team
This project was developed collaboratively by:
* **Samira** - IoT Hardware & System Integration (C++/ESP8266)
* **Zineb** - Mobile Application Development (Flutter)
* **Manal** - Backend Development & Database Management (Node.js/MySQL)

---
*Developed as a final project for University Abdelhamid Mehri – Constantine 2
Faculty of New Technologies of Information and Communication
Department of Software Technologies and Information Systems - 2026*
