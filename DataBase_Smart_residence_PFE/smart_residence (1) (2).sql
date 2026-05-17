-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 17, 2026 at 05:57 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `smart_residence`
--

-- --------------------------------------------------------

--
-- Table structure for table `accesslog`
--

CREATE TABLE `accesslog` (
  `id_log` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_name` varchar(100) DEFAULT NULL,
  `timestamp` datetime DEFAULT current_timestamp(),
  `action` enum('Granted','Denied') DEFAULT NULL,
  `device_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `accesslog`
--

INSERT INTO `accesslog` (`id_log`, `user_id`, `user_name`, `timestamp`, `action`, `device_id`) VALUES
(1, 29, 'khalil teir', '2026-05-01 23:23:02', 'Granted', NULL),
(2, 29, 'khalil teir', '2026-05-01 23:44:35', 'Granted', NULL),
(3, 29, 'khalil teir', '2026-05-02 00:44:32', 'Granted', NULL),
(4, 29, 'khalil teir', '2026-05-02 00:44:48', 'Granted', NULL),
(5, 25, 'djoud meraba', '2026-05-02 00:48:10', 'Granted', NULL),
(6, 29, 'khalil teir', '2026-05-02 00:52:20', 'Granted', NULL),
(7, 29, 'khalil teir', '2026-05-02 00:53:04', 'Granted', NULL),
(8, 25, 'djoud meraba', '2026-05-02 00:54:16', 'Granted', NULL),
(9, 25, 'djoud meraba', '2026-05-02 00:55:30', 'Granted', NULL),
(10, 29, 'khalil teir', '2026-05-02 00:57:23', 'Granted', NULL),
(11, 29, 'khalil teir', '2026-05-02 01:37:20', 'Denied', NULL),
(12, 29, 'khalil teir', '2026-05-02 01:38:23', 'Denied', NULL),
(13, 29, 'khalil teir', '2026-05-02 01:40:16', 'Denied', NULL),
(14, 29, 'khalil teir', '2026-05-02 01:40:54', 'Denied', NULL),
(15, 29, 'khalil teir', '2026-05-02 01:41:25', 'Denied', NULL),
(16, 29, 'khalil teir', '2026-05-02 01:42:06', 'Denied', NULL),
(17, 29, 'khalil teir', '2026-05-02 01:42:24', 'Denied', NULL),
(18, 29, 'khalil teir', '2026-05-02 01:42:32', 'Denied', NULL),
(19, 25, 'djoud meraba', '2026-05-04 17:14:05', 'Granted', NULL),
(20, 25, 'djoud meraba', '2026-05-04 17:22:12', 'Granted', NULL),
(21, 25, 'djoud meraba', '2026-05-04 17:32:07', 'Granted', NULL),
(22, 25, 'djoud meraba', '2026-05-04 17:36:06', 'Granted', NULL),
(23, 25, 'djoud meraba', '2026-05-04 20:47:07', 'Granted', NULL),
(24, 25, 'djoud meraba', '2026-05-04 21:24:52', 'Granted', NULL),
(25, 25, 'djoud meraba', '2026-05-04 21:32:24', 'Granted', NULL),
(26, 25, 'djoud meraba', '2026-05-04 21:35:35', 'Granted', NULL),
(27, 25, 'djoud meraba', '2026-05-04 21:53:52', 'Granted', NULL),
(28, 25, 'djoud meraba', '2026-05-04 22:47:41', 'Granted', NULL),
(29, 25, 'djoud meraba', '2026-05-04 22:49:54', 'Granted', NULL),
(30, 25, 'djoud meraba', '2026-05-04 22:51:19', 'Granted', NULL),
(31, 25, 'djoud meraba', '2026-05-04 23:05:46', 'Granted', NULL),
(32, 25, 'djoud meraba', '2026-05-04 23:16:27', 'Granted', NULL),
(33, 25, 'djoud meraba', '2026-05-05 12:49:19', 'Granted', NULL),
(34, 25, 'djoud meraba', '2026-05-05 13:00:46', 'Granted', NULL),
(35, 25, 'djoud meraba', '2026-05-05 13:01:50', 'Granted', NULL),
(36, 25, 'djoud meraba', '2026-05-05 13:16:41', 'Granted', NULL),
(37, 25, 'djoud meraba', '2026-05-05 13:17:03', 'Granted', NULL),
(38, 25, 'djoud meraba', '2026-05-05 15:11:43', 'Granted', NULL),
(39, 25, 'djoud meraba', '2026-05-11 22:00:41', 'Granted', NULL),
(40, 25, 'djoud meraba', '2026-05-11 22:11:55', 'Granted', NULL),
(41, 25, 'djoud meraba', '2026-05-11 22:12:35', 'Granted', NULL),
(42, 25, 'djoud meraba', '2026-05-11 22:50:55', 'Granted', NULL),
(43, 25, 'djoud meraba', '2026-05-11 23:01:22', 'Granted', NULL),
(44, 25, 'djoud meraba', '2026-05-14 07:10:02', 'Granted', NULL),
(45, 25, 'djoud meraba', '2026-05-14 12:34:38', 'Granted', NULL),
(46, 25, 'djoud meraba', '2026-05-14 12:34:47', 'Granted', NULL),
(47, 25, 'djoud meraba', '2026-05-14 12:34:57', 'Granted', NULL),
(48, 25, 'djoud meraba', '2026-05-14 14:08:43', 'Granted', NULL),
(49, 25, 'djoud meraba', '2026-05-14 14:09:13', 'Granted', NULL),
(50, 25, 'djoud meraba', '2026-05-14 14:16:20', 'Granted', NULL),
(51, 25, 'djoud meraba', '2026-05-14 14:16:36', 'Granted', NULL),
(52, 25, 'djoud meraba', '2026-05-14 14:21:27', 'Granted', NULL),
(53, 25, 'djoud meraba', '2026-05-16 17:15:52', 'Granted', NULL),
(54, 25, 'djoud meraba', '2026-05-16 17:16:03', 'Granted', NULL),
(55, 25, 'djoud meraba', '2026-05-16 17:17:54', 'Granted', NULL),
(56, 35, 'raouf dib', '2026-05-16 17:21:17', 'Granted', NULL),
(57, 35, 'raouf dib', '2026-05-16 17:21:44', 'Granted', NULL),
(58, 25, 'djoud meraba', '2026-05-16 18:23:32', 'Granted', NULL),
(59, 25, 'djoud meraba', '2026-05-16 18:24:00', 'Granted', NULL),
(60, 25, 'djoud meraba', '2026-05-16 18:27:24', 'Granted', NULL),
(61, 25, 'djoud meraba', '2026-05-16 18:31:39', 'Granted', NULL),
(62, 25, 'djoud meraba', '2026-05-16 18:43:05', 'Granted', NULL),
(63, 35, 'raouf dib', '2026-05-16 18:44:01', 'Granted', NULL),
(64, 25, 'djoud meraba', '2026-05-16 18:47:39', 'Granted', NULL),
(65, 25, 'djoud meraba', '2026-05-16 19:36:08', 'Granted', NULL),
(66, 25, 'djoud meraba', '2026-05-16 19:36:51', 'Granted', NULL),
(67, 35, 'raouf dib', '2026-05-16 19:37:05', 'Granted', NULL),
(68, 25, 'djoud meraba', '2026-05-16 21:16:35', 'Granted', NULL),
(69, 25, 'djoud meraba', '2026-05-16 22:15:05', 'Granted', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id_user` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id_user`) VALUES
(14);

-- --------------------------------------------------------

--
-- Table structure for table `alert`
--

CREATE TABLE `alert` (
  `id_Alert` int(11) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `category` enum('Plumbing','Electrical','Security','Fire') DEFAULT NULL,
  `source` varchar(50) DEFAULT NULL,
  `reportedBy_id` int(11) DEFAULT NULL,
  `urgencyLevel` enum('Low','Medium','High','Critical') DEFAULT NULL,
  `status` enum('pending','in progress','completed','canceled') DEFAULT NULL,
  `timeStamp` datetime DEFAULT NULL,
  `device_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `alert`
--

INSERT INTO `alert` (`id_Alert`, `title`, `description`, `category`, `source`, `reportedBy_id`, `urgencyLevel`, `status`, `timeStamp`, `device_id`) VALUES
(1, 'Water leak', 'water', 'Plumbing', 'Mobile App', 25, 'Medium', 'pending', '2026-05-03 02:03:28', NULL),
(2, 'fire', 'prblm', 'Electrical', 'Mobile App', 25, 'Medium', 'in progress', '2026-05-03 02:05:51', NULL),
(5, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 00:13:30', 1),
(6, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 00:28:18', 1),
(7, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 00:28:49', 1),
(8, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 00:39:42', 1),
(9, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 17:46:12', 1),
(10, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 17:46:16', 1),
(11, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 18:18:58', 1),
(12, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 18:25:02', 1),
(13, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 20:47:29', 1),
(14, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 20:47:32', 1),
(15, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 21:08:51', 1),
(16, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 21:23:58', 1),
(17, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 21:51:26', 1),
(18, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:32:30', 1),
(19, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:32:33', 1),
(20, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:32:35', 1),
(21, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:41:08', 1),
(22, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:41:10', 1),
(23, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:43:39', 1),
(24, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:43:51', 1),
(25, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:44:04', 1),
(26, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:44:07', 1),
(27, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:44:10', 1),
(28, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:44:25', 1),
(29, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:44:29', 1),
(30, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:44:39', 1),
(31, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:44:58', 1),
(32, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:45:32', 1),
(33, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:45:45', 1),
(34, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:46:35', 1),
(35, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:47:03', 1),
(36, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:47:54', 1),
(37, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:48:22', 1),
(38, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:48:59', 1),
(39, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:49:03', 1),
(40, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:49:42', 1),
(41, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:50:19', 1),
(42, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:50:47', 1),
(43, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:51:15', 1),
(44, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:51:27', 1),
(45, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:51:43', 1),
(46, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:51:45', 1),
(47, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:51:51', 1),
(48, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:51:57', 1),
(49, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:52:00', 1),
(50, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:52:02', 1),
(51, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:52:07', 1),
(52, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 22:52:21', 1),
(53, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:03:08', 1),
(54, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:03:31', 1),
(55, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:03:46', 1),
(56, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:04:09', 1),
(57, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:04:57', 1),
(58, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:05:54', 1),
(59, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:05:57', 1),
(60, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:06:01', 1),
(61, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:15:19', 1),
(62, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:15:32', 1),
(63, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:16:10', 1),
(64, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:16:53', 1),
(65, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:17:00', 1),
(66, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:17:07', 1),
(67, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:17:11', 1),
(68, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:17:14', 1),
(69, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:19:35', 1),
(70, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-04 23:54:02', 1),
(71, 'WATER LEAK ALERT', 'System detected a water leak (Simulated via Touch Sensor).', 'Plumbing', 'IoT Sensor', NULL, 'High', 'pending', '2026-05-05 00:29:45', 1),
(72, 'WATER LEAK ALERT', 'System detected a water leak (Simulated via Touch Sensor).', 'Plumbing', 'IoT Sensor', NULL, 'High', 'pending', '2026-05-05 00:32:51', 1),
(73, 'WATER LEAK ALERT', 'System detected a water leak (Simulated via Touch Sensor).', 'Plumbing', 'IoT Sensor', NULL, 'High', 'pending', '2026-05-05 00:40:09', 1),
(74, 'WATER LEAK ALERT', 'System detected a water leak (Simulated via Touch Sensor).', 'Plumbing', 'IoT Sensor', NULL, 'High', 'pending', '2026-05-05 00:40:26', 1),
(75, 'WATER LEAK ALERT', 'System detected a water leak (Simulated via Touch Sensor).', 'Plumbing', 'IoT Sensor', NULL, 'High', 'pending', '2026-05-05 01:00:40', 1),
(76, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:47:38', 1),
(77, 'WATER LEAK ALERT', 'System detected a water leak (Simulated via Touch Sensor).', 'Plumbing', 'IoT Sensor', NULL, 'High', 'pending', '2026-05-05 12:48:08', 1),
(78, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:50:35', 1),
(79, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:52:09', 1),
(80, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:52:15', 1),
(81, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:52:22', 1),
(82, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:52:52', 1),
(83, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:53:51', 1),
(84, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:54:28', 1),
(85, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:55:49', 1),
(86, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:56:52', 1),
(87, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:57:18', 1),
(88, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:58:20', 1),
(89, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:58:41', 1),
(90, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 12:59:42', 1),
(91, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 13:02:06', 1),
(92, 'WATER LEAK ALERT', 'System detected a water leak (Simulated via Touch Sensor).', 'Plumbing', 'IoT Sensor', NULL, 'High', 'pending', '2026-05-05 13:03:53', 1),
(93, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 13:07:46', 1),
(94, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 13:09:28', 1),
(95, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 13:10:25', 1),
(96, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 13:34:23', 1),
(97, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 14:27:14', 1),
(98, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 14:27:25', 1),
(99, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-05 15:13:27', 1),
(100, 'WATER LEAK ALERT', 'System detected a water leak (Simulated via Touch Sensor).', 'Plumbing', 'IoT Sensor', NULL, 'High', 'pending', '2026-05-05 15:14:53', 1),
(101, 'water leak', 'prblm', 'Plumbing', 'Mobile App', 34, 'High', 'pending', '2026-05-05 15:28:24', NULL),
(102, 'WATER LEAK ALERT', 'System detected a water leak (Simulated via Touch Sensor).', 'Plumbing', 'IoT Sensor', NULL, 'High', 'pending', '2026-05-08 21:22:17', 1),
(103, 'WATER LEAK ALERT', 'System detected a water leak (Simulated via Touch Sensor).', 'Plumbing', 'IoT Sensor', NULL, 'High', 'pending', '2026-05-08 21:38:02', 1),
(104, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-08 21:38:03', 1),
(105, 'WATER LEAK ALERT', 'System detected a water leak (Simulated via Touch Sensor).', 'Plumbing', 'IoT Sensor', NULL, 'High', 'pending', '2026-05-08 21:57:30', 1),
(106, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-08 21:57:31', 1),
(107, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-08 22:10:04', 1),
(108, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-08 22:10:49', 1),
(109, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-08 22:10:52', 1),
(110, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-11 22:12:55', 1),
(111, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-11 22:24:41', 1),
(112, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-11 22:24:43', 1),
(113, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-11 22:24:47', 1),
(114, 'IoT Fire Alert', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-11 22:24:57', 1),
(115, 'dog enter', 'dog', 'Security', 'Mobile App', 25, 'High', 'in progress', '2026-05-13 22:51:09', NULL),
(116, 'QUICK ALERT: Plumbing', 'Emergency reported via Quick Button for Plumbing issues.', 'Plumbing', 'Mobile Quick Action', 25, 'Critical', 'pending', '2026-05-14 14:26:56', NULL),
(117, 'QUICK ALERT: Electrical', 'Emergency reported via Quick Button for Electrical issues.', 'Electrical', 'Mobile Quick Action', 25, 'Critical', 'pending', '2026-05-14 14:27:14', NULL),
(118, 'QUICK ALERT: Security', 'User reported an urgent Security issue via Quick Action button.', 'Security', 'Mobile Quick Button', 25, 'Critical', 'pending', '2026-05-14 14:33:08', NULL),
(119, 'QUICK ALERT: Fire', 'User reported an urgent Fire issue via Quick Action button.', 'Fire', 'Mobile Quick Button', 25, 'Critical', 'pending', '2026-05-14 14:41:45', NULL),
(120, 'water', 'prblm fire', 'Fire', 'Mobile App', 25, 'Critical', 'pending', '2026-05-14 14:42:52', NULL),
(121, 'QUICK ALERT: Fire', 'User reported an urgent Fire issue via Quick Action button.', 'Fire', 'Mobile Quick Button', 25, 'Critical', 'pending', '2026-05-14 15:44:16', NULL),
(122, 'QUICK ALERT: Security', 'User reported an urgent Security issue via Quick Action button.', 'Security', 'Mobile Quick Button', 25, 'Critical', 'in progress', '2026-05-14 15:53:04', NULL),
(123, 'IoT FIRE ALERT', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-16 17:18:42', 1),
(124, 'QUICK ALERT: Plumbing', 'User reported an urgent Plumbing issue via Quick Action button.', 'Plumbing', 'Mobile Quick Button', 25, 'Critical', 'pending', '2026-05-16 17:42:03', NULL),
(125, 'IoT FIRE ALERT', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-16 18:49:04', 1),
(126, 'water', 'water', 'Plumbing', 'Mobile App', 25, 'Medium', 'in progress', '2026-05-16 20:16:04', NULL),
(127, 'QUICK ALERT: Fire', 'User reported an urgent Fire issue via Quick Action button.', 'Fire', 'Mobile Quick Button', 25, 'Critical', 'pending', '2026-05-16 20:16:11', NULL),
(128, 'QUICK ALERT: Plumbing', 'User reported an urgent Plumbing issue via Quick Action button.', 'Plumbing', 'Mobile Quick Button', 25, 'Critical', 'pending', '2026-05-16 20:16:20', NULL),
(129, 'QUICK ALERT: Cleaning', 'User reported an urgent Cleaning issue via Quick Action button.', '', 'Mobile Quick Button', 25, 'Critical', 'in progress', '2026-05-16 20:16:27', NULL),
(130, 'IoT FIRE ALERT', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-16 21:14:03', 1),
(131, 'IoT FIRE ALERT', 'Emergency: Fire detected by IoT Device ID: 1', 'Fire', 'IoT System', NULL, 'Critical', 'pending', '2026-05-16 21:14:09', 1),
(132, 'QUICK ALERT: Plumbing', 'User reported an urgent Plumbing issue via Quick Action button.', 'Plumbing', 'Mobile Quick Button', 25, 'Critical', 'pending', '2026-05-16 23:51:33', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apartment`
--

CREATE TABLE `apartment` (
  `id_apartment` int(11) NOT NULL,
  `blockNumber` varchar(20) DEFAULT NULL,
  `doorNumber` varchar(50) NOT NULL,
  `floor` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `apartment`
--

INSERT INTO `apartment` (`id_apartment`, `blockNumber`, `doorNumber`, `floor`) VALUES
(7, 'Block A', 'A-31', 3),
(8, 'Block A', 'A-32', 3),
(9, 'Block A', 'A-33', 3),
(10, 'Block A', 'A-34', 3),
(11, 'Block A', 'A-41', 4),
(12, 'Block A', 'A-42', 4),
(13, 'Block A', 'A-43', 4),
(14, 'Block A', 'A-44', 4),
(15, 'Block B', 'B-21', 2),
(16, 'Block B', 'B-22', 2),
(17, 'Block B', 'B-23', 2),
(18, 'Block B', 'B-24', 2),
(19, 'Block B', 'B-31', 3),
(20, 'Block B', 'B-32', 3),
(21, 'Block B', 'B-33', 3),
(22, 'Block B', 'B-34', 3),
(23, 'Block C', 'C-11', 1),
(24, 'Block C', 'C-12', 1),
(25, 'Block C', 'C-13', 1),
(26, 'Block C', 'C-14', 1),
(27, 'Block C', 'C-21', 2),
(28, 'Block C', 'C-22', 2),
(29, 'Block C', 'C-23', 2),
(30, 'Block C', 'C-24', 2),
(31, 'Block D', 'D-11', 1),
(32, 'Block D', 'D-12', 1),
(33, 'Block D', 'D-13', 1),
(34, 'Block D', 'D-14', 1),
(35, 'Block D', 'D-21', 2),
(36, 'Block D', 'D-22', 2);

-- --------------------------------------------------------

--
-- Table structure for table `comment`
--

CREATE TABLE `comment` (
  `id_comment` int(11) NOT NULL,
  `post_id` int(11) DEFAULT NULL,
  `author_id` int(11) DEFAULT NULL,
  `text` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `conversation`
--

CREATE TABLE `conversation` (
  `id_conversation` int(11) NOT NULL,
  `participant1_Id` int(11) DEFAULT NULL,
  `participant2_Id` int(11) DEFAULT NULL,
  `lastMessage` text DEFAULT NULL,
  `lastUpdate` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `conversation`
--

INSERT INTO `conversation` (`id_conversation`, `participant1_Id`, `participant2_Id`, `lastMessage`, `lastUpdate`) VALUES
(40, 25, 26, 'hey', '2026-05-16 22:56:52'),
(142, 25, 28, 'hey', '2026-05-06 16:28:41'),
(143, 25, 14, 'hey', '2026-05-17 00:00:12'),
(144, 25, 34, 'heyyy', '2026-05-07 21:52:52'),
(145, 26, 14, 'hey', '2026-05-07 21:57:25');

-- --------------------------------------------------------

--
-- Table structure for table `event`
--

CREATE TABLE `event` (
  `id_Event` int(11) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `eventDate` date DEFAULT NULL,
  `time` time DEFAULT NULL,
  `endTime` time DEFAULT NULL,
  `isPublic` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `organizer_id` int(11) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `event`
--

INSERT INTO `event` (`id_Event`, `title`, `description`, `eventDate`, `time`, `endTime`, `isPublic`, `created_at`, `organizer_id`, `status`) VALUES
(12, 'community meeting ', 'meeting communityyyYY', '2026-05-24', '18:00:00', '21:00:00', 1, '2026-04-30 20:25:25', 14, 'Approved'),
(14, 'birthday ', 'party', '2026-05-31', '14:30:00', '19:00:00', 1, '2026-05-01 13:17:48', 28, 'Approved'),
(16, 'warda', 'warda', '2026-05-21', '12:00:00', '13:30:00', 1, '2026-05-01 14:07:22', 25, 'Approved'),
(21, 'bac', 'bac', '2026-05-28', '18:30:00', '10:30:00', 1, '2026-05-06 23:38:24', 25, 'Approved'),
(22, 'bac party', 'party', '2026-05-20', '18:30:00', '21:30:00', 1, '2026-05-14 11:15:45', 25, 'pending'),
(23, 'bac party', 'party', '2026-05-22', '10:30:00', '16:30:00', 1, '2026-05-14 11:43:46', 25, 'Approved'),
(24, 'METTING', 'METINGn', '2026-05-25', '21:30:00', '11:30:00', 1, '2026-05-14 13:57:00', 14, 'Approved'),
(25, 'bith', 'birh', '2026-05-19', '10:30:00', '12:30:00', 1, '2026-05-16 15:43:06', 25, 'Approved'),
(26, 'bac', 'bac', '2026-05-20', '06:07:00', '08:07:00', 1, '2026-05-16 18:15:28', 25, 'Approved'),
(27, 'zeineb', 'zzeineb', '2026-05-18', '18:30:00', '22:30:00', 1, '2026-05-16 21:04:29', 25, 'pending'),
(28, 'soutenons ', 'party', '2026-05-19', '14:30:00', '19:30:00', 1, '2026-05-16 21:54:36', 25, 'pending');

-- --------------------------------------------------------

--
-- Table structure for table `eventattendance`
--

CREATE TABLE `eventattendance` (
  `id_Attendance` int(11) NOT NULL,
  `id_user` int(11) DEFAULT NULL,
  `id_Event` int(11) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `eventattendance`
--

INSERT INTO `eventattendance` (`id_Attendance`, `id_user`, `id_Event`, `status`) VALUES
(18, 25, 12, 'Joined'),
(19, 28, 12, 'Joined');

-- --------------------------------------------------------

--
-- Table structure for table `guestparking`
--

CREATE TABLE `guestparking` (
  `id_spot` int(11) NOT NULL,
  `spot_number` varchar(10) DEFAULT NULL,
  `is_occupied` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `guestparking`
--

INSERT INTO `guestparking` (`id_spot`, `spot_number`, `is_occupied`) VALUES
(1, 'G1', 1),
(2, 'G2', 1),
(3, 'G3', 1),
(4, 'G4', 1),
(5, 'G5', 0),
(6, 'G6', 0),
(7, 'G7', 0),
(8, 'G8', 0),
(9, 'G9', 0),
(10, 'G10', 0),
(11, 'G11', 0),
(12, 'G12', 0),
(13, 'G13', 0),
(14, 'G14', 0),
(15, 'G15', 0);

-- --------------------------------------------------------

--
-- Table structure for table `iotdevices`
--

CREATE TABLE `iotdevices` (
  `id_device` int(11) NOT NULL,
  `device_name` varchar(100) DEFAULT NULL,
  `status` enum('Online','Offline','Maintenance','Error') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `iotdevices`
--

INSERT INTO `iotdevices` (`id_device`, `device_name`, `status`) VALUES
(1, 'Flame Sensor 01', 'Online');

-- --------------------------------------------------------

--
-- Table structure for table `maintenancestaff`
--

CREATE TABLE `maintenancestaff` (
  `id_user` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `id_message` int(11) NOT NULL,
  `conversation_id` int(11) DEFAULT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `content` text DEFAULT NULL,
  `timestamp` datetime DEFAULT current_timestamp(),
  `is_read` tinyint(1) DEFAULT 0,
  `is_edited` tinyint(1) DEFAULT 0,
  `message_type` enum('text','voice') DEFAULT 'text'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `message`
--

INSERT INTO `message` (`id_message`, `conversation_id`, `sender_id`, `receiver_id`, `content`, `timestamp`, `is_read`, `is_edited`, `message_type`) VALUES
(1, 40, 25, NULL, 'hey', '2026-05-06 15:14:52', 1, 0, 'text'),
(2, 40, 26, NULL, 'hey', '2026-05-06 15:19:49', 1, 0, 'text'),
(11, 143, 25, NULL, 'hey', '2026-05-06 17:06:58', 1, 0, 'text'),
(12, 144, 25, NULL, 'hey', '2026-05-06 17:07:34', 0, 0, 'text'),
(14, 144, 25, NULL, 'hey', '2026-05-06 19:41:31', 0, 0, 'text'),
(15, 144, 25, NULL, 'hey', '2026-05-06 19:50:55', 0, 0, 'text'),
(16, 40, 26, NULL, 'hey', '2026-05-06 20:12:51', 1, 0, 'text'),
(17, 40, 25, NULL, 'HEY', '2026-05-06 20:13:58', 1, 0, 'text'),
(19, 40, 26, NULL, 'hey', '2026-05-06 20:34:19', 1, 0, 'text'),
(21, 40, 26, NULL, 'hey', '2026-05-06 21:52:35', 1, 0, 'text'),
(22, 40, 25, NULL, 'hello', '2026-05-06 23:33:41', 1, 1, 'text'),
(28, 143, 25, NULL, 'hey', '2026-05-07 20:54:29', 1, 0, 'text'),
(30, 144, 25, NULL, 'HEY', '2026-05-07 21:04:16', 0, 0, 'text'),
(31, 143, 25, NULL, 'hey', '2026-05-07 21:11:45', 1, 0, 'text'),
(32, 40, 25, NULL, 'heyYYYY', '2026-05-07 21:13:55', 1, 1, 'text'),
(33, 144, 25, 34, 'heyyy', '2026-05-07 21:52:52', 0, 0, 'text'),
(34, 40, 25, 26, 'hello', '2026-05-07 21:53:19', 1, 0, 'text'),
(35, 145, 26, 14, 'hey', '2026-05-07 21:57:11', 1, 0, 'text'),
(36, 145, 26, 14, 'hey', '2026-05-07 21:57:16', 1, 0, 'text'),
(37, 145, 26, 14, 'hey', '2026-05-07 21:57:25', 1, 0, 'text'),
(38, 143, 14, 25, 'hey', '2026-05-07 23:21:05', 1, 0, 'text'),
(39, 143, 14, 25, 'heYY', '2026-05-07 23:54:06', 1, 1, 'text'),
(40, 143, 14, 25, 'hey', '2026-05-07 23:55:24', 1, 0, 'text'),
(41, 40, 25, 26, 'hey', '2026-05-14 13:11:41', 0, 0, 'text'),
(42, 143, 25, 14, 'hey', '2026-05-14 13:41:09', 1, 0, 'text'),
(43, 143, 25, 14, 'gggggggggggggggggggggg', '2026-05-14 13:41:16', 1, 0, 'text'),
(44, 143, 14, 25, '22222222222', '2026-05-14 13:41:42', 1, 0, 'text'),
(45, 143, 14, 25, 'hey', '2026-05-16 20:42:34', 1, 0, 'text'),
(46, 143, 14, 25, 'hey', '2026-05-16 20:43:50', 1, 0, 'text'),
(47, 143, 25, 14, 'hey', '2026-05-16 21:58:11', 1, 0, 'text'),
(48, 143, 14, 25, 'hey', '2026-05-16 22:00:16', 1, 0, 'text'),
(49, 40, 25, 26, 'hey', '2026-05-16 22:56:51', 0, 0, 'text'),
(50, 143, 25, 14, 'hey', '2026-05-16 23:03:15', 1, 0, 'text'),
(51, 143, 25, 14, 'hey', '2026-05-16 23:42:46', 1, 0, 'text'),
(52, 143, 25, 14, 'hey 👋🏻', '2026-05-16 23:49:21', 1, 0, 'text'),
(53, 143, 25, 14, 'hey', '2026-05-16 23:55:15', 0, 0, 'text'),
(54, 143, 25, 14, 'hey', '2026-05-17 00:00:12', 0, 0, 'text');

-- --------------------------------------------------------

--
-- Table structure for table `notification`
--

CREATE TABLE `notification` (
  `id_notification` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `title` varchar(100) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `type` enum('Event','Reservation','Alert','Message','System') DEFAULT 'System',
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notification`
--

INSERT INTO `notification` (`id_notification`, `user_id`, `title`, `message`, `type`, `is_read`, `created_at`) VALUES
(1, 25, 'Reservation Confirmed Successfully', 'Your booking for \"undefined\" on 2026-05-16 from 09:30:00 to 12:30:00 has been confirmed.', 'Reservation', 1, '2026-05-16 15:25:24'),
(2, 25, 'Reservation Confirmed Successfully', 'Your booking for \"Shared Space\" on 2026-05-20 from 14:30:00 to 18:30:00 has been confirmed.', 'Reservation', 1, '2026-05-16 15:39:58'),
(3, 14, 'New Maintenance Alert (Critical)', 'A new issue has been reported in the (Plumbing) category titled: \"QUICK ALERT: Plumbing\". Please review it and assign a maintenance staff member.', 'Alert', 0, '2026-05-16 15:42:03'),
(4, 14, 'New Event Approval Request', 'A resident has requested to create an event titled: \"bith\". Please review and approve it.', 'Event', 0, '2026-05-16 15:43:06'),
(5, 25, 'Reservation Confirmed Successfully', 'Your booking for \"Shared Space\" on 2026-05-19 from 18:30:00 to 21:00:00 has been confirmed.', 'Reservation', 1, '2026-05-16 16:01:25'),
(6, 25, 'Reservation Confirmed Successfully', 'Your booking for \"Shared Space\" on 2026-05-26 from 18:30:00 to 21:30:00 has been confirmed.', 'Reservation', 1, '2026-05-16 16:40:48'),
(7, 25, 'Reservation Confirmed Successfully', 'Your booking for \"Shared Space\" on 2026-05-17 from 09:00:00 to 11:30:00 has been confirmed.', 'Reservation', 1, '2026-05-16 16:46:13'),
(8, 25, 'Reservation Confirmed Successfully', 'Your booking for \"Shared Space\" on 2026-05-18 from 18:30:00 to 22:00:00 has been confirmed.', 'Reservation', 1, '2026-05-16 16:58:01'),
(9, 25, 'Reservation Confirmed Successfully', 'Your booking for \"Shared Space\" on 2026-05-19 from 08:00:00 to 10:30:00 has been confirmed.', 'Reservation', 1, '2026-05-16 17:08:22'),
(10, 25, 'Reservation Confirmed Successfully', 'Your booking for \"Shared Space\" on 2026-05-18 from 17:00:00 to 21:30:00 has been confirmed.', 'Reservation', 1, '2026-05-16 17:13:37'),
(11, 25, 'Reservation Confirmed Successfully', 'Your booking for \"Library\" on 2026-05-20 from 18:06:00 to 19:30:00 has been confirmed.', 'Reservation', 1, '2026-05-16 18:14:48'),
(12, 14, 'New Event Approval Request', 'A resident has requested to create an event titled: \"bac\". Please review and approve it.', 'Event', 0, '2026-05-16 18:15:28'),
(13, 14, 'New Maintenance Alert (Medium)', 'A new issue has been reported in the (Plumbing) category titled: \"water\". Please review it and assign a maintenance staff member.', 'Alert', 0, '2026-05-16 18:16:05'),
(14, 14, 'New Maintenance Alert (Critical)', 'A new issue has been reported in the (Fire) category titled: \"QUICK ALERT: Fire\". Please review it and assign a maintenance staff member.', 'Alert', 0, '2026-05-16 18:16:11'),
(15, 14, 'New Maintenance Alert (Critical)', 'A new issue has been reported in the (Plumbing) category titled: \"QUICK ALERT: Plumbing\". Please review it and assign a maintenance staff member.', 'Alert', 0, '2026-05-16 18:16:20'),
(16, 14, 'New Maintenance Alert (Critical)', 'A new issue has been reported in the (Cleaning) category titled: \"QUICK ALERT: Cleaning\". Please review it and assign a maintenance staff member.', 'Alert', 0, '2026-05-16 18:16:28'),
(17, 25, 'New Message from lokman meraba', 'hey', 'Message', 1, '2026-05-16 18:42:34'),
(18, 25, 'New Message from lokman meraba', 'hey', 'Message', 1, '2026-05-16 18:43:50'),
(19, 14, 'New Message from djoud meraba', 'hey', 'Message', 0, '2026-05-16 19:58:11'),
(21, 25, 'New Message from lokman meraba', 'hey', 'Message', 1, '2026-05-16 20:00:16'),
(22, 26, 'New Message from djoud meraba', 'hey', 'Message', 0, '2026-05-16 20:56:52'),
(23, 14, 'New Message from djoud meraba', 'hey', 'Message', 0, '2026-05-16 21:03:15'),
(24, 14, 'New Event Approval Request', 'A resident has requested to create an event titled: \"zeineb\". Please review and approve it.', 'Event', 0, '2026-05-16 21:04:29'),
(25, 14, 'New Message from djoud meraba', 'hey', 'Message', 0, '2026-05-16 21:42:46'),
(26, 14, 'New Message from djoud meraba', 'hey 👋🏻', 'Message', 1, '2026-05-16 21:49:21'),
(27, 14, 'New Maintenance Alert (Critical)', 'A new issue has been reported in the (Plumbing) category titled: \"QUICK ALERT: Plumbing\". Please review it and assign a maintenance staff member.', 'Alert', 0, '2026-05-16 21:51:33'),
(28, 14, 'New Event Approval Request', 'A resident has requested to create an event titled: \"soutenons \". Please review and approve it.', 'Event', 0, '2026-05-16 21:54:36'),
(29, 14, 'New Message from djoud meraba', 'hey', 'Message', 0, '2026-05-16 21:55:16'),
(30, 14, 'New Message from djoud meraba', 'hey', 'Message', 1, '2026-05-16 22:00:12');

-- --------------------------------------------------------

--
-- Table structure for table `parking`
--

CREATE TABLE `parking` (
  `id_parking` int(11) NOT NULL,
  `spot_name` varchar(10) NOT NULL,
  `status` enum('Available','Occupied','Automatically') DEFAULT 'Available',
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `parking`
--

INSERT INTO `parking` (`id_parking`, `spot_name`, `status`, `user_id`) VALUES
(1, 'P01', 'Available', NULL),
(2, 'P02', 'Occupied', NULL),
(3, 'P03', 'Occupied', NULL),
(4, 'P04', 'Available', NULL),
(5, 'P05', 'Occupied', NULL),
(6, 'P06', 'Occupied', NULL),
(7, 'P07', 'Occupied', NULL),
(8, 'P08', 'Available', NULL),
(9, 'P09', 'Available', NULL),
(10, 'P10', 'Occupied', NULL),
(11, 'P11', 'Available', NULL),
(12, 'P12', 'Available', NULL),
(13, 'P13', 'Occupied', NULL),
(14, 'P14', 'Available', NULL),
(15, 'P15', 'Available', NULL),
(16, 'P16', 'Occupied', NULL),
(17, 'P17', 'Available', NULL),
(18, 'P18', 'Available', NULL),
(19, 'P19', 'Occupied', NULL),
(20, 'P20', 'Available', NULL),
(21, 'P21', 'Available', NULL),
(22, 'P22', 'Occupied', NULL),
(23, 'P23', 'Available', NULL),
(24, 'P24', 'Available', NULL),
(25, 'P25', 'Occupied', NULL),
(26, 'P26', 'Available', NULL),
(27, 'P27', 'Available', NULL),
(28, 'P28', 'Occupied', NULL),
(29, 'P29', 'Available', NULL),
(30, 'P30', 'Available', NULL),
(31, 'P31', 'Occupied', NULL),
(32, 'P32', 'Available', NULL),
(33, 'P33', 'Available', NULL),
(34, 'P34', 'Occupied', NULL),
(35, 'P35', 'Available', NULL),
(36, 'P36', 'Available', NULL),
(37, 'P37', 'Occupied', NULL),
(38, 'P38', 'Available', NULL),
(39, 'P39', 'Available', NULL),
(40, 'P40', 'Occupied', NULL),
(41, 'P41', 'Available', NULL),
(42, 'P42', 'Available', NULL),
(43, 'P43', 'Occupied', NULL),
(44, 'P44', 'Available', NULL),
(45, 'P45', 'Available', NULL),
(46, 'P46', 'Occupied', NULL),
(47, 'P47', 'Available', NULL),
(48, 'P48', 'Available', NULL),
(49, 'P49', 'Occupied', NULL),
(50, 'P50', 'Available', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `post`
--

CREATE TABLE `post` (
  `id_post` int(11) NOT NULL,
  `author_id` int(11) DEFAULT NULL,
  `content` text DEFAULT NULL,
  `postType` varchar(20) DEFAULT NULL,
  `timestamp` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `postlikes`
--

CREATE TABLE `postlikes` (
  `id_post` int(11) NOT NULL,
  `id_user` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reservation`
--

CREATE TABLE `reservation` (
  `id_Reservation` int(11) NOT NULL,
  `space_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `reservationDate` date DEFAULT NULL,
  `startTime` time DEFAULT NULL,
  `endTime` time DEFAULT NULL,
  `status` enum('Approved','Cancelled') DEFAULT 'Approved'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reservation`
--

INSERT INTO `reservation` (`id_Reservation`, `space_id`, `user_id`, `reservationDate`, `startTime`, `endTime`, `status`) VALUES
(1, 9, 25, '2026-05-04', '17:30:00', '19:00:00', 'Approved'),
(2, 9, 25, '2026-05-15', '17:30:00', '19:00:00', 'Approved'),
(3, 9, 25, '2026-05-03', '18:00:00', '20:30:00', 'Approved'),
(7, 8, 25, '2026-05-19', '16:30:00', '21:00:00', 'Approved'),
(10, 9, 25, '2026-05-20', '14:30:00', '18:30:00', 'Approved'),
(11, 7, 25, '2026-05-19', '18:30:00', '21:00:00', 'Approved'),
(12, 8, 25, '2026-05-26', '18:30:00', '21:30:00', 'Approved'),
(16, 8, 25, '2026-05-18', '17:00:00', '21:30:00', 'Approved'),
(17, 7, 25, '2026-05-20', '18:06:00', '19:30:00', 'Approved');

-- --------------------------------------------------------

--
-- Table structure for table `resident`
--

CREATE TABLE `resident` (
  `id_user` int(11) NOT NULL,
  `apartmentNumber` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `resident`
--

INSERT INTO `resident` (`id_user`, `apartmentNumber`) VALUES
(25, 'A-33'),
(26, 'A-33'),
(29, 'A-33'),
(34, 'A-34'),
(28, 'B-34');

-- --------------------------------------------------------

--
-- Table structure for table `securitystaff`
--

CREATE TABLE `securitystaff` (
  `id_user` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `securitystaff`
--

INSERT INTO `securitystaff` (`id_user`) VALUES
(35);

-- --------------------------------------------------------

--
-- Table structure for table `sharedspace`
--

CREATE TABLE `sharedspace` (
  `id_space` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `isAvailable` tinyint(1) DEFAULT 1,
  `openTime` time DEFAULT NULL,
  `closeTime` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sharedspace`
--

INSERT INTO `sharedspace` (`id_space`, `name`, `category`, `capacity`, `isAvailable`, `openTime`, `closeTime`) VALUES
(7, 'Library', 'Indoor', 20, 1, '06:30:00', '22:00:00'),
(8, 'BBQ Spot', 'Outdoor', 15, 1, '10:00:00', '22:00:00'),
(9, 'Garden Table', 'Outdoor', 8, 1, '08:00:00', '23:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `task`
--

CREATE TABLE `task` (
  `id_Task` int(11) NOT NULL,
  `alert_id` int(11) DEFAULT NULL,
  `staff_id` int(11) DEFAULT NULL,
  `assignedDate` datetime DEFAULT NULL,
  `status` enum('pending','in progress','completed','canceled') DEFAULT NULL,
  `staffRemarks` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `task`
--

INSERT INTO `task` (`id_Task`, `alert_id`, `staff_id`, `assignedDate`, `status`, `staffRemarks`) VALUES
(2, 115, 35, '2026-05-13 22:52:38', 'completed', NULL),
(3, 115, 35, '2026-05-14 00:04:27', 'in progress', 'Updated by staff'),
(4, 122, 35, '2026-05-14 15:53:19', 'in progress', 'Updated by staff');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id_user` int(11) NOT NULL,
  `fullName` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `phoneNumber` varchar(20) DEFAULT NULL,
  `qrCodeData` text DEFAULT NULL,
  `role` enum('Resident','Admin','SecurityStaff','MaintenanceStaff') DEFAULT NULL,
  `status` enum('Active','pending','Inactive') DEFAULT NULL,
  `security_question` enum('What is your childhood nickname ?','What was your first pet''s name?','What is a memorable place from your childhood?','What is your favorite teacher''s name?') DEFAULT NULL,
  `securityAnswer` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `rfid_uid` varchar(50) DEFAULT NULL,
  `job_type` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id_user`, `fullName`, `email`, `password`, `phoneNumber`, `qrCodeData`, `role`, `status`, `security_question`, `securityAnswer`, `created_at`, `rfid_uid`, `job_type`) VALUES
(14, 'lokman meraba', 'lokman@gmail.com', '$2b$10$45q22KPBPqVpLlYGK7hLgewgEmhSPdF4uY1CBtDrylba.sFoOiQiq', '0667544206', NULL, 'Admin', 'Active', 'What was your first pet\'s name?', 'macha', '2026-04-17 21:14:44', NULL, NULL),
(25, 'djoud meraba', 'djoud@gmail.com', '$2b$10$DDVTvrIdyp.eZbCOE831m.XAm6pRUBmn/d1C1NVQIiu7ILCBEsLcy', '0776544523', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAANzSURBVO3BO67kWgIDwcyD2v+WOW08g5YAQao7/WGE+YWZ/xxmymGmHGbKYaYcZsphphxmymGmHGbKYaYcZsphphxmymGmHGbKh4dUflISnlC5koSmciUJV1R+UhKeOMyUw0w5zJQPL0vCm1SuqLQkvCkJTaWptCRcScKbVN50mCmHmXKYKR++TOWOJHxTEn4nKnck4ZsOM+UwUw4z5cNfRqUl4YpKS0JT+ZccZsphphxmyoc/XBKuqLQkXFFpSbii8jc5zJTDTDnMlA9floSfpHJFpSXhDpWWhCeS8Ds5zJTDTDnMlA8vU/lJKi0JTaUloam0JDSVloSm0pJwReV3dpgph5lymCnmF/5gKleS0FTuSMK/5DBTDjPlMFM+PKTSkvAmlZaEO1RaEq6oXFFpSWgqV5JwReWOJLzpMFMOM+UwUz68TKUloam0JFxJQlNpSfgmlSsqLQlvSkJT+abDTDnMlMNM+fBQEq6otCQ0lZaEptKScEWlJeGbknBFpSXhd3aYKYeZcpgp5hceUGlJuEPlShKayh1JuEOlJeFNKi0JV1TuSMITh5lymCmHmfLhoSR8k8qVJDSVKyotCS0JTeVKEprKT0rCmw4z5TBTDjPF/MIDKleS0FRaEu5QeSIJTaUl4SepXElCU7mShCcOM+UwUw4z5cPLktBUWhKuqNyRhKbSknAlCU+oXElCU7mShDuS8KbDTDnMlMNM+fBlSWgqdyShqTSVJ1SeSEJTuSMJTaUloSWhqbQkPHGYKYeZcpgpH75MpSXhDpWWhKbypiQ0lZaEpnJF5YrKFZUrSXjTYaYcZsphpphf+IOp3JGEN6m0JNyh0pJwh0pLwhOHmXKYKYeZ8uEhlZ+UhJaEJ1TuSMIdKi0Jd6i0JHzTYaYcZsphpnx4WRLepPImlZaEb0rCHSotCT/pMFMOM+UwUz58mcodSXhC5f9J5ZtUvukwUw4z5TBTPvxjktBU7khCS8I3qbQkNJU3HWbKYaYcZsqHv0wSmsqVJDSVKypPJKGp/E4OM+UwUw4z5cOXJeEnqbQkXFG5koSm0pJwh8qVJNyRhDcdZsphphxmyoeXqfwklSsq36TSktBU7lB5IglPHGbKYaYcZor5hZn/HGbKYaYcZsphphxmymGmHGbKYaYcZsphphxmymGmHGbKYaYcZsr/AGc8byo09JH7AAAAAElFTkSuQmCC', 'Resident', 'Active', 'What is your childhood nickname ?', 'ahmed', '2026-04-28 17:22:19', NULL, NULL),
(26, 'samira adjenf', 'samira@gmail.com', '$2b$10$8l00L0UECtiLq.CmOtpNZu4PHkXX59zV21z83oCuxmPbHmyoeP88G', '0556765432', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOlSURBVO3BQW7dWAADwe6Hf/8rc7zIgisBgmQnHrDKfGHmj8NMOcyUw0w5zJTDTDnMlMNMOcyUw0w5zJTDTDnMlMNMOcyUw0z58JDKT0pCU2lJeJPKlSRcUflJSXjiMFMOM+UwUz68LAlvUrlDpSWhqbQkNJU7VFoSriThTSpvOsyUw0w5zJQP30zljiT8JJUrSWgqLQlPqNyRhO90mCmHmXKYKR9+uSQ0labSktBUWhKayhWVloTf7DBTDjPlMFM+/HIqLQlN5Q6VK0loKv8nh5lymCmHmfLhmyXhOyWhqVxRuZKEKypvSsK/5DBTDjPlMFM+vEzlJ6m0JDSVloSmckWlJaGp3KHyLzvMlMNMOcyUDw8l4W9KQlNpSfhOSbiShN/kMFMOM+UwUz48pNKScEXlb1K5IwlN5Y4kXFFpSWgqdyThicNMOcyUw0wxX3iRypuS0FRaEprKlSRcUXkiCU+otCQ0lZaENx1mymGmHGbKh4dUWhLepHJF5Q6VloQrSWgqLQlN5UoSmsodSfhOh5lymCmHmfLhZSotCXeotCQ0lStJaCpvSkJTuZKEptKS8IRKS8ITh5lymCmHmfLhoSQ0lTtUWhKaSkvCFZWWhDuS0FSuJKGpNJUnVK4k4U2HmXKYKYeZYr7wgEpLQlNpSbii0pLQVK4koam0JDSVO5LwhEpLQlNpSWgqV5LwxGGmHGbKYaaYLzygciUJV1RaEppKS8IVlZaEO1RaEu5QaUm4otKS0FSuJOFNh5lymCmHmfLhZUloKi0JLQlXknBF5YpKS0JTuaJyJQl3qLQkNJWWhCsqLQlPHGbKYaYcZor5wgMqLQl3qDyRhDtUriThDpWflITvdJgph5lymCnmC7+YyhNJeEKlJeEOlZaEpnJHEp44zJTDTDnMlA8PqfykJFxJwh0qdyThDpWWhCeS0FTedJgph5lymCkfXpaEN6k8oXIlCU3lTUm4Q6Ul4ScdZsphphxmyodvpnJHEv4lSWgqV1TepPKTDjPlMFMOM+XD/4xKS8IVlSsqV5LwnVRaEprKmw4z5TBTDjPlwy+XhKZyRaUloam0JDSVptKS0FRaEq6oXFH5ToeZcpgph5ny4Zsl4Scl4Q6VN6m0JDSVK0loKleS8KbDTDnMlMNM+fAylZ+k0pLwNyWhqdyhcodKS8ITh5lymCmHmWK+MPPHYaYcZsphphxmymGmHGbKYaYcZsphphxmymGmHGbKYaYcZsphpvwHeIqOQXA1K7QAAAAASUVORK5CYII=', 'Resident', 'Active', 'What is your childhood nickname ?', 'mimi', '2026-04-29 22:17:40', NULL, NULL),
(28, 'zeineb meraba', 'zeineb@gmail.com', '$2b$10$J20ZjuHt6b4k56bmEN8oF.CE4KjMmCpiRD76vsfg08k29a4mik/Hm', '0776689945', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOnSURBVO3BQY4kRwIDQfdA/f/L3DnsgacAElnd0gg0M38w83+HmXKYKYeZcpgph5lymCmHmXKYKYeZcpgph5lymCmHmXKYKYeZ8uElld+UhKZyk4Sm0pJwo3KThBuV35SENw4z5TBTDjPlw5cl4ZtU3lBpSbhReUKlJeEmCd+k8k2HmXKYKYeZ8uGHqTyRhDeS0FTeSEJTaUl4Q+WJJPykw0w5zJTDTPnwl0tCU3kjCU3lRqUl4W92mCmHmXKYKR/+ciotCU3lCZWbJDSV/5LDTDnMlMNM+fDDkvCTknCThKbSktCScKPyTUn4NznMlMNMOcyUD1+m8ptUWhKaSktCU2lJaCotCU3lCZV/s8NMOcyUw0wxf/AfotKS0FRaEm5UWhL+yw4z5TBTDjPlw0sqLQk3Kj8pCU2lJaGptCS0JDSVJ5Jwo9KS0FSeSMIbh5lymCmHmWL+4B+k0pLwhkpLwhMqbyThDZWWhKbSkvBNh5lymCmHmfLhh6ncJKGp3CThJgk3Ki0JN0loKi0JTeUmCU3liST8pMNMOcyUw0z58JJKS8IbSbhReSIJNypPJKGp3CShqbQkvKHSkvDGYaYcZsphppg/eEHlNyXhRuWJJNyo3CShqTyRhBuVmyR802GmHGbKYaZ8+LIkNJWbJHxTEppKS0JTeSIJN0m4UblRaUloKk2lJeGNw0w5zJTDTDF/8ILKTRJuVFoSmkpLwo1KS8ITKi0JT6i0JNyotCQ0lZskfNNhphxmymGmfPiyJNyo3Ki0JDSVloQblZaEpnKjcpOEJ1RaEppKS8KNSkvCG4eZcpgph5li/uAFlZaEpvJPSkJTuUnCEyq/KQk/6TBTDjPlMFPMH/zFVN5IwhsqLQlPqLQkNJUnkvDGYaYcZsphpnx4SeU3JeEmCU2lJaGpPJGEJ1RaEt5IQlP5psNMOcyUw0z58GVJ+CaVb1JpSWgq35SEJ1RaEn7TYaYcZsphpnz4YSpPJOENlZaEpvJEEprKjco3qfymw0w5zJTDTPnwH5OEmyQ0lRuVloSm0pLwTSotCU3lmw4z5TBTDjPlw18uCU+otCQ0lZaEN1RaEm5UblR+0mGmHGbKYaZ8+GFJ+Cep3Kg8oXKj0pLQVG6S0FRukvBNh5lymCmHmfLhy1R+k0pLQktCU/lJSWgqT6g8odKS8MZhphxmymGmmD+Y+b/DTDnMlMNMOcyUw0w5zJTDTDnMlMNMOcyUw0w5zJTDTDnMlMNM+R87i54iy6pvagAAAABJRU5ErkJggg==', 'Resident', 'Active', 'What is your childhood nickname ?', 'nouha', '2026-04-29 22:19:52', NULL, NULL),
(29, 'khalil teir', 'khalil@gmail.com', '$2b$10$2aQ6HrW0PANxQbFgpAW9FOgRLhpD/RwN7nf0hBAzBCUNlXEvxGHsq', '097787766', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAASmSURBVO3BQY4bSRAEwfAC//9l3znmqYBGJ2clIczwR6qWnFQtOqladFK16KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYs+eQnIb1IzAXlCzQRkk5pNQH6TmjdOqhadVC06qVr0yTI1m4DcqLkBcqNmAjKp2QTkRs2Nmk1ANp1ULTqpWnRSteiTLwPyhJo3gExqJiA3aiYgN2omIDdqNgF5Qs03nVQtOqladFK16JO/HJBJzY2aGyCTmgnIjZoJyARkUvMvOaladFK16KRq0Sf/GCBvqJmA3ACZ1Nyo+ZedVC06qVp0UrXoky9T85vUTEAmNTdAJjU3QCYgN0Bu1Dyh5k9yUrXopGrRSdWiT5YB+ZsAmdRMQCY1N2omIJOaCcgTQP5kJ1WLTqoWnVQt+uQlNX8yNROQN4DcAJnUvKHmb3JSteikatFJ1SL8kReATGqeADKpmYB8k5pNQJ5QMwHZpOYGyKTmjZOqRSdVi06qFuGP/EGATGreADKpuQEyqZmAvKHmCSC/Sc0bJ1WLTqoWnVQt+uTLgLwB5EbNBGRS84SaJ9TcALkB8oSaCcik5gkgm06qFp1ULTqpWvTJl6mZgDyhZgLyBpBJzRNqboBMam7U3ACZgExqJiCTmgnIN51ULTqpWnRSteiTX6ZmAnID5JuATGp+E5AbNROQGzVPqNl0UrXopGrRSdUi/JEXgExqJiBPqLkB8oaaGyDfpOYJIL9JzRsnVYtOqhadVC36ZBmQSc0bQG7UTEAmNTdAvknNDZBJzaRmAvKGmgnIppOqRSdVi06qFn2yTM0EZFIzAblRcwNkk5obIJOaCcgE5A0gT6i5AfJNJ1WLTqoWnVQt+mQZkEnNBORGzQRkUvN/UjMBuVEzAbkBMqn5JjWbTqoWnVQtOqla9MkfTs2NmhsgTwDZBGRS8wSQN9TcAJnUvHFSteikatFJ1aJPXlKzCcgmNROQGzUTkCfUTECeADKpmYBMam6ATGomIJtOqhadVC06qVqEP/I/AnKj5gbIpGYCcqPmBsikZgKySc0EZFLzBpAbNW+cVC06qVp0UrXok5eA3Kh5A8ik5gbIjZoJyKTmm9RMQCYgN0CeUDOpmYBsOqladFK16KRq0ScvqXlDzW8CMql5AsgbQG7UPAFkUvN/OqladFK16KRq0ScvAflNam7UTEAmNTdAnlBzA+QNIJOaGyA3ar7ppGrRSdWik6pFnyxTswnIjZpNaiYgN0CeUDMBuVHzhJobIJOaTSdVi06qFp1ULfrky4A8oeYJIE8AeUPNDZBJzQTkBsgbQCY1k5oJyKTmjZOqRSdVi06qFn3yl1PzBJAbNROQCciNmhs1E5AbNX+Tk6pFJ1WLTqoWffKPATKpmdRMQCYgk5oJyKTmDTWbgPyfTqoWnVQtOqla9MmXqflNap5QMwF5A8iNmgnIE2qeUDMB+aaTqkUnVYtOqhZ9sgzIbwJyo2YC8gSQN9Q8oWYCcgPkDTWbTqoWnVQtOqlahD9SteSkatFJ1aKTqkUnVYtOqhadVC06qVp0UrXopGrRSdWik6pFJ1WLTqoWnVQtOqla9B98rgJeDadbGQAAAABJRU5ErkJggg==', 'Resident', 'Inactive', 'What was your first pet\'s name?', 'mimi', '2026-05-01 20:25:45', NULL, NULL),
(34, 'loulou', 'loulou@gmail.com', '$2b$10$i3xdXI6Iwfbb.gkqGK7au.o998HQ8vmEbf6hbtTuaXtWPobRERHP2', '0667896543', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAASmSURBVO3BQY4bSRAEwfAC//9l3znmqYBGJ2clIczwR6qWnFQtOqladFK16KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYs+eQnIb1IzAXlCzQRkk5pNQH6TmjdOqhadVC06qVr0yTI1m4DcqLkBcqNmAjKp2QTkRs2Nmk1ANp1ULTqpWnRSteiTLwPyhJo3gExqJiA3aiYgN2omIDdqNgF5Qs03nVQtOqladFK16JO/HJBJzY2aGyCTmgnIjZoJyARkUvMvOaladFK16KRq0Sf/GCBvqJmA3ACZ1Nyo+ZedVC06qVp0UrXoky9T85vUTEAmNTdAJjU3QCYgN0Bu1Dyh5k9yUrXopGrRSdWiT5YB+ZsAmdRMQCY1N2omIJOaCcgTQP5kJ1WLTqoWnVQt+uQlNX8yNROQN4DcAJnUvKHmb3JSteikatFJ1SL8kReATGqeADKpmYB8k5pNQJ5QMwHZpOYGyKTmjZOqRSdVi06qFuGP/EGATGreADKpuQEyqZmAvKHmCSC/Sc0bJ1WLTqoWnVQt+uTLgLwB5EbNBGRS84SaJ9TcALkB8oSaCcik5gkgm06qFp1ULTqpWvTJl6mZgDyhZgLyBpBJzRNqboBMam7U3ACZgExqJiCTmgnIN51ULTqpWnRSteiTX6ZmAnID5JuATGp+E5AbNROQGzVPqNl0UrXopGrRSdUi/JEXgExqJiBPqLkB8oaaGyDfpOYJIL9JzRsnVYtOqhadVC36ZBmQSc0bQG7UTEAmNTdAvknNDZBJzaRmAvKGmgnIppOqRSdVi06qFn2yTM0EZFIzAblRcwNkk5obIJOaCcgE5A0gT6i5AfJNJ1WLTqoWnVQt+mQZkEnNBORGzQRkUvN/UjMBuVEzAbkBMqn5JjWbTqoWnVQtOqla9MkfTs2NmhsgTwDZBGRS8wSQN9TcAJnUvHFSteikatFJ1aJPXlKzCcgmNROQGzUTkCfUTECeADKpmYBMam6ATGomIJtOqhadVC06qVqEP/I/AnKj5gbIpGYCcqPmBsikZgKySc0EZFLzBpAbNW+cVC06qVp0UrXok5eA3Kh5A8ik5gbIjZoJyKTmm9RMQCYgN0CeUDOpmYBsOqladFK16KRq0ScvqXlDzW8CMql5AsgbQG7UPAFkUvN/OqladFK16KRq0ScvAflNam7UTEAmNTdAnlBzA+QNIJOaGyA3ar7ppGrRSdWik6pFnyxTswnIjZpNaiYgN0CeUDMBuVHzhJobIJOaTSdVi06qFp1ULfrky4A8oeYJIE8AeUPNDZBJzQTkBsgbQCY1k5oJyKTmjZOqRSdVi06qFn3yl1PzBJAbNROQCciNmhs1E5AbNX+Tk6pFJ1WLTqoWffKPATKpmdRMQCYgk5oJyKTmDTWbgPyfTqoWnVQtOqla9MmXqflNap5QMwF5A8iNmgnIE2qeUDMB+aaTqkUnVYtOqhZ9sgzIbwJyo2YC8gSQN9Q8oWYCcgPkDTWbTqoWnVQtOqlahD9SteSkatFJ1aKTqkUnVYtOqhadVC06qVp0UrXopGrRSdWik6pFJ1WLTqoWnVQtOqla9B98rgJeDadbGQAAAABJRU5ErkJggg==', 'Resident', 'Active', 'What is your childhood nickname ?', 'mimi', '2026-05-05 13:18:23', NULL, NULL),
(35, 'raouf dib', 'raouf@gmail.com', '$2b$10$LFPXecafIy8YafEfBvPwyuprLfMfDgxlzemLJw2cjnGTAqFtZF4Au', '0556454322', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAASmSURBVO3BQY4bSRAEwfAC//9l3znmqYBGJ2clIczwR6qWnFQtOqladFK16KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYs+eQnIb1IzAXlCzQRkk5pNQH6TmjdOqhadVC06qVr0yTI1m4DcqLkBcqNmAjKp2QTkRs2Nmk1ANp1ULTqpWnRSteiTLwPyhJo3gExqJiA3aiYgN2omIDdqNgF5Qs03nVQtOqladFK16JO/HJBJzY2aGyCTmgnIjZoJyARkUvMvOaladFK16KRq0Sf/GCBvqJmA3ACZ1Nyo+ZedVC06qVp0UrXoky9T85vUTEAmNTdAJjU3QCYgN0Bu1Dyh5k9yUrXopGrRSdWiT5YB+ZsAmdRMQCY1N2omIJOaCcgTQP5kJ1WLTqoWnVQt+uQlNX8yNROQN4DcAJnUvKHmb3JSteikatFJ1SL8kReATGqeADKpmYB8k5pNQJ5QMwHZpOYGyKTmjZOqRSdVi06qFuGP/EGATGreADKpuQEyqZmAvKHmCSC/Sc0bJ1WLTqoWnVQt+uTLgLwB5EbNBGRS84SaJ9TcALkB8oSaCcik5gkgm06qFp1ULTqpWvTJl6mZgDyhZgLyBpBJzRNqboBMam7U3ACZgExqJiCTmgnIN51ULTqpWnRSteiTX6ZmAnID5JuATGp+E5AbNROQGzVPqNl0UrXopGrRSdUi/JEXgExqJiBPqLkB8oaaGyDfpOYJIL9JzRsnVYtOqhadVC36ZBmQSc0bQG7UTEAmNTdAvknNDZBJzaRmAvKGmgnIppOqRSdVi06qFn2yTM0EZFIzAblRcwNkk5obIJOaCcgE5A0gT6i5AfJNJ1WLTqoWnVQt+mQZkEnNBORGzQRkUvN/UjMBuVEzAbkBMqn5JjWbTqoWnVQtOqla9MkfTs2NmhsgTwDZBGRS8wSQN9TcAJnUvHFSteikatFJ1aJPXlKzCcgmNROQGzUTkCfUTECeADKpmYBMam6ATGomIJtOqhadVC06qVqEP/I/AnKj5gbIpGYCcqPmBsikZgKySc0EZFLzBpAbNW+cVC06qVp0UrXok5eA3Kh5A8ik5gbIjZoJyKTmm9RMQCYgN0CeUDOpmYBsOqladFK16KRq0ScvqXlDzW8CMql5AsgbQG7UPAFkUvN/OqladFK16KRq0ScvAflNam7UTEAmNTdAnlBzA+QNIJOaGyA3ar7ppGrRSdWik6pFnyxTswnIjZpNaiYgN0CeUDMBuVHzhJobIJOaTSdVi06qFp1ULfrky4A8oeYJIE8AeUPNDZBJzQTkBsgbQCY1k5oJyKTmjZOqRSdVi06qFn3yl1PzBJAbNROQCciNmhs1E5AbNX+Tk6pFJ1WLTqoWffKPATKpmdRMQCYgk5oJyKTmDTWbgPyfTqoWnVQtOqla9MmXqflNap5QMwF5A8iNmgnIE2qeUDMB+aaTqkUnVYtOqhZ9sgzIbwJyo2YC8gSQN9Q8oWYCcgPkDTWbTqoWnVQtOqlahD9SteSkatFJ1aKTqkUnVYtOqhadVC06qVp0UrXopGrRSdWik6pFJ1WLTqoWnVQtOqla9B98rgJeDadbGQAAAABJRU5ErkJggg==', 'SecurityStaff', 'Active', 'What is your childhood nickname ?', 'alaa', '2026-05-13 19:12:36', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `visitorrequest`
--

CREATE TABLE `visitorrequest` (
  `id_request` int(11) NOT NULL,
  `apartment_id` int(11) DEFAULT NULL,
  `guest_name` varchar(100) DEFAULT NULL,
  `guest_phone` varchar(20) DEFAULT NULL,
  `requestTime` datetime DEFAULT NULL,
  `visit_time` varchar(20) DEFAULT NULL,
  `duration_hours` int(11) DEFAULT NULL,
  `needs_parking` tinyint(1) DEFAULT NULL,
  `spot_id` int(11) DEFAULT NULL,
  `qr_code_token` varchar(255) DEFAULT NULL,
  `status` enum('Pending','Accepted','Denied','Leave_at_gate') DEFAULT 'Accepted'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `visitorrequest`
--

INSERT INTO `visitorrequest` (`id_request`, `apartment_id`, `guest_name`, `guest_phone`, `requestTime`, `visit_time`, `duration_hours`, `needs_parking`, `spot_id`, `qr_code_token`, `status`) VALUES
(1, 25, 'zeineb', '0797544206', '2026-05-19 00:00:00', '5:30 PM', 3, 0, NULL, 'f7ec9d3a531e795353b30e00b709c470', 'Accepted'),
(2, 25, 'manel', '05564532221', '2026-05-19 00:00:00', '5:30 PM', 5, 1, 1, 'c11dbee5a9b371a9c1ecda1d427a9660', 'Accepted'),
(3, 25, 'manel', '06675543422', '2026-05-15 00:00:00', '6:30 PM', 3, 1, 2, 'c3de6f635bf56a7ae848215bc0bd55fa', 'Accepted'),
(4, 25, 'loulou', '06678544321', '2026-05-13 00:00:00', '12:30 PM', 3, 1, 3, 'f1ac32885a9f160087463b8a6ed99605', 'Accepted'),
(5, 28, 'samira adjenf', '066754453211', '2026-05-18 00:00:00', '9:19 PM', 5, 1, 4, 'e542559bc208fc5ff29b171d898c2e69', 'Accepted');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accesslog`
--
ALTER TABLE `accesslog`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `fk_accesslog_iot` (`device_id`);

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id_user`);

--
-- Indexes for table `alert`
--
ALTER TABLE `alert`
  ADD PRIMARY KEY (`id_Alert`),
  ADD KEY `reportedBy_id` (`reportedBy_id`),
  ADD KEY `fk_alert_iot` (`device_id`);

--
-- Indexes for table `apartment`
--
ALTER TABLE `apartment`
  ADD PRIMARY KEY (`id_apartment`),
  ADD UNIQUE KEY `doorNumber` (`doorNumber`);

--
-- Indexes for table `comment`
--
ALTER TABLE `comment`
  ADD PRIMARY KEY (`id_comment`),
  ADD KEY `post_id` (`post_id`),
  ADD KEY `author_id` (`author_id`);

--
-- Indexes for table `conversation`
--
ALTER TABLE `conversation`
  ADD PRIMARY KEY (`id_conversation`),
  ADD KEY `participant1_Id` (`participant1_Id`),
  ADD KEY `participant2_Id` (`participant2_Id`);

--
-- Indexes for table `event`
--
ALTER TABLE `event`
  ADD PRIMARY KEY (`id_Event`),
  ADD KEY `organizer_id` (`organizer_id`);

--
-- Indexes for table `eventattendance`
--
ALTER TABLE `eventattendance`
  ADD PRIMARY KEY (`id_Attendance`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `id_Event` (`id_Event`);

--
-- Indexes for table `guestparking`
--
ALTER TABLE `guestparking`
  ADD PRIMARY KEY (`id_spot`),
  ADD UNIQUE KEY `spot_number` (`spot_number`);

--
-- Indexes for table `iotdevices`
--
ALTER TABLE `iotdevices`
  ADD PRIMARY KEY (`id_device`);

--
-- Indexes for table `maintenancestaff`
--
ALTER TABLE `maintenancestaff`
  ADD PRIMARY KEY (`id_user`);

--
-- Indexes for table `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`id_message`),
  ADD KEY `conversation_id` (`conversation_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `fk_receiver` (`receiver_id`);

--
-- Indexes for table `notification`
--
ALTER TABLE `notification`
  ADD PRIMARY KEY (`id_notification`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `parking`
--
ALTER TABLE `parking`
  ADD PRIMARY KEY (`id_parking`),
  ADD UNIQUE KEY `spot_name` (`spot_name`),
  ADD KEY `fk_parking_user_resident` (`user_id`);

--
-- Indexes for table `post`
--
ALTER TABLE `post`
  ADD PRIMARY KEY (`id_post`),
  ADD KEY `author_id` (`author_id`);

--
-- Indexes for table `postlikes`
--
ALTER TABLE `postlikes`
  ADD PRIMARY KEY (`id_post`,`id_user`),
  ADD KEY `id_user` (`id_user`);

--
-- Indexes for table `reservation`
--
ALTER TABLE `reservation`
  ADD PRIMARY KEY (`id_Reservation`),
  ADD KEY `space_id` (`space_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `resident`
--
ALTER TABLE `resident`
  ADD PRIMARY KEY (`id_user`),
  ADD KEY `apartmentNumber` (`apartmentNumber`);

--
-- Indexes for table `securitystaff`
--
ALTER TABLE `securitystaff`
  ADD PRIMARY KEY (`id_user`);

--
-- Indexes for table `sharedspace`
--
ALTER TABLE `sharedspace`
  ADD PRIMARY KEY (`id_space`);

--
-- Indexes for table `task`
--
ALTER TABLE `task`
  ADD PRIMARY KEY (`id_Task`),
  ADD KEY `alert_id` (`alert_id`),
  ADD KEY `staff_id` (`staff_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `visitorrequest`
--
ALTER TABLE `visitorrequest`
  ADD PRIMARY KEY (`id_request`),
  ADD KEY `apartment_id` (`apartment_id`),
  ADD KEY `spot_id` (`spot_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accesslog`
--
ALTER TABLE `accesslog`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

--
-- AUTO_INCREMENT for table `alert`
--
ALTER TABLE `alert`
  MODIFY `id_Alert` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT for table `apartment`
--
ALTER TABLE `apartment`
  MODIFY `id_apartment` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `comment`
--
ALTER TABLE `comment`
  MODIFY `id_comment` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `conversation`
--
ALTER TABLE `conversation`
  MODIFY `id_conversation` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=146;

--
-- AUTO_INCREMENT for table `event`
--
ALTER TABLE `event`
  MODIFY `id_Event` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `eventattendance`
--
ALTER TABLE `eventattendance`
  MODIFY `id_Attendance` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `guestparking`
--
ALTER TABLE `guestparking`
  MODIFY `id_spot` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `iotdevices`
--
ALTER TABLE `iotdevices`
  MODIFY `id_device` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `message`
--
ALTER TABLE `message`
  MODIFY `id_message` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `notification`
--
ALTER TABLE `notification`
  MODIFY `id_notification` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `parking`
--
ALTER TABLE `parking`
  MODIFY `id_parking` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `post`
--
ALTER TABLE `post`
  MODIFY `id_post` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reservation`
--
ALTER TABLE `reservation`
  MODIFY `id_Reservation` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `sharedspace`
--
ALTER TABLE `sharedspace`
  MODIFY `id_space` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `task`
--
ALTER TABLE `task`
  MODIFY `id_Task` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `visitorrequest`
--
ALTER TABLE `visitorrequest`
  MODIFY `id_request` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `accesslog`
--
ALTER TABLE `accesslog`
  ADD CONSTRAINT `accesslog_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id_user`),
  ADD CONSTRAINT `fk_accesslog_iot` FOREIGN KEY (`device_id`) REFERENCES `iotdevices` (`id_device`) ON DELETE SET NULL;

--
-- Constraints for table `admin`
--
ALTER TABLE `admin`
  ADD CONSTRAINT `admin_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `alert`
--
ALTER TABLE `alert`
  ADD CONSTRAINT `alert_ibfk_1` FOREIGN KEY (`reportedBy_id`) REFERENCES `user` (`id_user`),
  ADD CONSTRAINT `fk_alert_iot` FOREIGN KEY (`device_id`) REFERENCES `iotdevices` (`id_device`) ON DELETE SET NULL;

--
-- Constraints for table `comment`
--
ALTER TABLE `comment`
  ADD CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `post` (`id_post`) ON DELETE CASCADE,
  ADD CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `user` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `conversation`
--
ALTER TABLE `conversation`
  ADD CONSTRAINT `conversation_ibfk_1` FOREIGN KEY (`participant1_Id`) REFERENCES `user` (`id_user`),
  ADD CONSTRAINT `conversation_ibfk_2` FOREIGN KEY (`participant2_Id`) REFERENCES `user` (`id_user`);

--
-- Constraints for table `event`
--
ALTER TABLE `event`
  ADD CONSTRAINT `event_ibfk_1` FOREIGN KEY (`organizer_id`) REFERENCES `user` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `eventattendance`
--
ALTER TABLE `eventattendance`
  ADD CONSTRAINT `eventattendance_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE,
  ADD CONSTRAINT `eventattendance_ibfk_2` FOREIGN KEY (`id_Event`) REFERENCES `event` (`id_Event`) ON DELETE CASCADE;

--
-- Constraints for table `maintenancestaff`
--
ALTER TABLE `maintenancestaff`
  ADD CONSTRAINT `maintenancestaff_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `message`
--
ALTER TABLE `message`
  ADD CONSTRAINT `fk_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `user` (`id_user`),
  ADD CONSTRAINT `message_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `conversation` (`id_conversation`) ON DELETE CASCADE,
  ADD CONSTRAINT `message_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `user` (`id_user`);

--
-- Constraints for table `notification`
--
ALTER TABLE `notification`
  ADD CONSTRAINT `notification_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `parking`
--
ALTER TABLE `parking`
  ADD CONSTRAINT `fk_parking_user_resident` FOREIGN KEY (`user_id`) REFERENCES `user` (`id_user`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `post`
--
ALTER TABLE `post`
  ADD CONSTRAINT `post_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `user` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `postlikes`
--
ALTER TABLE `postlikes`
  ADD CONSTRAINT `postlikes_ibfk_1` FOREIGN KEY (`id_post`) REFERENCES `post` (`id_post`) ON DELETE CASCADE,
  ADD CONSTRAINT `postlikes_ibfk_2` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `reservation`
--
ALTER TABLE `reservation`
  ADD CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`space_id`) REFERENCES `sharedspace` (`id_space`),
  ADD CONSTRAINT `reservation_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id_user`);

--
-- Constraints for table `resident`
--
ALTER TABLE `resident`
  ADD CONSTRAINT `resident_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE,
  ADD CONSTRAINT `resident_ibfk_2` FOREIGN KEY (`apartmentNumber`) REFERENCES `apartment` (`doorNumber`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `securitystaff`
--
ALTER TABLE `securitystaff`
  ADD CONSTRAINT `securitystaff_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `task`
--
ALTER TABLE `task`
  ADD CONSTRAINT `task_ibfk_1` FOREIGN KEY (`alert_id`) REFERENCES `alert` (`id_Alert`) ON DELETE CASCADE,
  ADD CONSTRAINT `task_ibfk_2` FOREIGN KEY (`staff_id`) REFERENCES `user` (`id_user`);

--
-- Constraints for table `visitorrequest`
--
ALTER TABLE `visitorrequest`
  ADD CONSTRAINT `visitorrequest_ibfk_1` FOREIGN KEY (`apartment_id`) REFERENCES `apartment` (`id_apartment`),
  ADD CONSTRAINT `visitorrequest_ibfk_2` FOREIGN KEY (`spot_id`) REFERENCES `guestparking` (`id_spot`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
