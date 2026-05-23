# 🏢 Smart Residence Management System

## 🌟 Overview
The **Smart Residence Management System** is a comprehensive, IoT-integrated solution designed to modernize and secure residential complexes. It seamlessly connects hardware sensors, a robust backend server, a relational database, and cross-platform mobile applications to provide a smart, automated living experience for residents, administrators, and security staff.

## ✨ Key Features
* 🚪 **Smart Gate Access:** Secure entry system using personalized QR codes for residents ,staff and guests .
* 🔥 **Emergency Fire Detection:** Real-time flame monitoring that instantly triggers critical alerts to the system , admin dashboard and residents mobile app .
* 🚗 **Smart Parking Management:** Ultrasonic sensors detect vehicle presence to update parking availability (Available/Occupied) in real-time.
* 💡 **Intelligent Lighting:** Automated street lighting based on night-mode configuration and motion/IR detection.
* 📱 **Cross-Platform Mobile Apps:** Dedicated Flutter applications for end-users (Residents) and management (Admins/Security).

## 🛠️ Technologies & Tools Used
* **IoT & Hardware:** ESP8266 (NodeMCU), Ultrasonic Sensor (HC-SR04), Flame Sensor, IR Sensor, I2C LCD Display, C++ (Arduino IDE/VS Code), Wokwi Simulator.
* **Backend:** Node.js, Express.js, RESTful APIs.
* **Database:** MySQL.
* **Mobile App and Web Dashboard (Frontend):** Flutter (Dart).
* **Web Services:** HTML/JS/CSS for Web QR Scanner, Cloudflare Tunnels (for secure localhost exposure).

## 📂 Repository Structure
This repository contains the full source code of the project, divided into the following modules:

* `Backend_Smart_Residence_PFE/` : Contains the Node.js API source code and backend configurations.
* `DataBase_Smart_residence_PFE/` : Contains the database schema (`smart_residence.sql`) and sample data for MySQL.
* `Frontend_Smart_Residence_PFE/` : Contains the mobile and dashboard applications, split into:
  * `admin_residence/` : The web dashboard/app for system administrators and security management.
  * `appresidence/` : The mobile application dedicated to the residents.
* `lot_Smart_Residence_PFE/` : Contains the IoT and hardware configurations, split into:
  * `IOT Simulation Parking Wokwi/` : The Wokwi simulation configurations for the smart parking system.
  * `Smart Lighting Gate Fire Alert IOT Code/` : The ESP8266 C++ code for automated lighting, gate control, and fire alerts.
  * `Web_QR_Scanner/` : The HTML/JS web interface used for gate QR code verification.

## 👥 Meet the Team
This project was developed collaboratively by:
* **Samira Adjenef** - IoT Hardware & System Integration (C++/ESP8266)
* **Zineb meraba** - Mobile Application Development & Web Dashboard (Flutter)
* **Manal teir** - Backend Development & Database Management (Node.js/MySQL)

---
*Developed as a final project for University Abdelhamid Mehri – Constantine 2
Faculty of New Technologies of Information and Communication
Department of Software Technologies and Information Systems - 2026*
