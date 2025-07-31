-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 31, 2025 at 08:18 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `liyag_batangan`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_account`
--

CREATE TABLE `admin_account` (
  `admin_id` int(11) NOT NULL,
  `role` enum('SuperAdmin','SupportAdmin') DEFAULT 'SuperAdmin'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cart_item`
--

CREATE TABLE `cart_item` (
  `cart_item_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) DEFAULT 1,
  `price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cart_item`
--

INSERT INTO `cart_item` (`cart_item_id`, `user_id`, `product_id`, `quantity`, `price`) VALUES
(21, 35, 25, 1, 130.00),
(22, 35, 31, 1, 300.00),
(27, 32, 31, 1, 300.00);

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

CREATE TABLE `cart_items` (
  `cart_item_id` int(11) NOT NULL,
  `cart_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customer_account`
--

CREATE TABLE `customer_account` (
  `customer_id` int(11) NOT NULL,
  `preferred_shipping_address` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delivery`
--

CREATE TABLE `delivery` (
  `delivery_id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `courier_name` varchar(100) DEFAULT NULL,
  `tracking_number` varchar(100) DEFAULT NULL,
  `delivery_status` enum('Preparing','Out for Delivery','Delivered') DEFAULT 'Preparing',
  `estimated_arrival` date DEFAULT NULL,
  `delivery_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `email_verification`
--

CREATE TABLE `email_verification` (
  `email` varchar(255) NOT NULL,
  `otp_code` varchar(6) DEFAULT NULL,
  `otp_expiry` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `email_verification`
--

INSERT INTO `email_verification` (`email`, `otp_code`, `otp_expiry`) VALUES
('alexandraannonuevo@gmail.com', '669505', '2025-07-30 08:31:25'),
('ariescanubasasi@gmail.com', '195533', '2025-07-30 10:25:47'),
('christian.loowis@gmail.com', '107185', '2025-07-30 03:00:32'),
('florenciasaludaga1968@gmail.com', '883247', '2025-07-25 21:20:01'),
('florsaludaga1968@gmail.com', '912870', '2025-07-25 21:22:36'),
('gilbertsaludaga89@gmail.com', '645759', '2025-07-16 06:29:59');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`notification_id`, `user_id`, `title`, `message`, `is_read`, `created_at`) VALUES
(1, 5, 'Welcome to Liyag Batangan!', 'Hi there! We’re thrilled to have you onboard. Start browsing delicious food, unique pasalubongs, and amazing local stores. Thank you for supporting our community!', 0, '2025-07-02 16:50:20'),
(2, 13, 'Welcome to Liyag Batangan!', 'Thank you for registering! Start exploring local delicacies and offers today.', 0, '2025-07-02 17:13:43'),
(10, 5, '🛍️ Business Submission Received', 'Thank you for submitting \"hsgsfsffafs\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-02 18:51:45'),
(12, 5, '🛍️ Business Submission Received', 'Thank you for submitting \"my euli\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-02 19:01:20'),
(13, 5, '✅ Business Approved!', 'Congratulations! Your business \"my euli\" has been approved.', 0, '2025-07-02 19:01:30'),
(14, 13, '🛍️ Business Submission Received', 'Thank you for submitting \"Santo\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-02 19:57:51'),
(15, 13, '✅ Business Approved!', 'Congratulations! Your business \"Santo\" has been approved.', 0, '2025-07-02 19:58:03'),
(17, 5, '🛍️ Business Submission Received', 'Thank you for submitting \"Beach House\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-02 20:14:56'),
(18, 5, '✅ Business Approved!', 'Congratulations! Your business \"Beach House\" has been approved.', 0, '2025-07-02 20:15:14'),
(19, 15, 'Welcome to Liyag Batangan!', 'Thank you for registering! Start exploring local delicacies and offers today.', 0, '2025-07-03 14:00:19'),
(22, 17, '🛍️ Business Submission Received', 'Thank you for submitting \"Louis\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-04 17:44:15'),
(23, 17, '❌ Business Rejected', 'We\'re sorry. Your business \"Louis\" has been rejected.', 0, '2025-07-04 17:46:33'),
(24, 17, '🛍️ Business Submission Received', 'Thank you for submitting \"Louis\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-04 17:47:04'),
(25, 17, '✅ Business Approved!', 'Congratulations! Your business \"Louis\" has been approved.', 0, '2025-07-04 17:47:17'),
(26, 18, 'Welcome to Liyag Batangan!', 'Thank you for registering! Start exploring local delicacies and offers today.', 0, '2025-07-05 12:18:47'),
(27, 18, '🛍️ Business Submission Received', 'Thank you for submitting \"sisig123\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-05 12:19:59'),
(28, 18, '❌ Business Rejected', 'We\'re sorry. Your business \"sisig123\" has been rejected.', 0, '2025-07-05 12:21:02'),
(29, 18, '🛍️ Business Submission Received', 'Thank you for submitting \"sisig nga\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-05 12:21:37'),
(30, 18, '✅ Business Approved!', 'Congratulations! Your business \"sisig nga\" has been approved.', 0, '2025-07-05 12:21:45'),
(31, 25, 'Welcome to Liyag Batangan!', 'Thank you for registering! Start exploring local delicacies and offers today.', 0, '2025-07-15 14:14:33'),
(36, 32, 'Welcome to Liyag Batangan!', 'Thank you for registering! Start exploring local delicacies and offers today.', 0, '2025-07-16 04:25:23'),
(37, 32, '🛍️ Business Submission Received', 'Thank you for submitting \"Balisong\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-23 06:32:27'),
(38, 32, '✅ Business Approved!', 'Congratulations! Your business \"Balisong\" has been approved.', 0, '2025-07-23 06:36:29'),
(39, 32, '🛍️ Business Submission Received', 'Thank you for submitting \"Cat\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-23 06:42:25'),
(40, 32, '🛍️ Business Submission Received', 'Thank you for submitting \"Liyag\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-23 06:46:47'),
(41, 32, '❌ Business Rejected', 'We\'re sorry. Your business \"Cat\" has been rejected.', 0, '2025-07-23 06:47:07'),
(42, 32, '✅ Business Approved!', 'Congratulations! Your business \"Liyag\" has been approved.', 0, '2025-07-23 06:47:14'),
(43, 32, '🛍️ Business Submission Received', 'Thank you for submitting \"Liyag\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-23 06:53:18'),
(44, 32, '❌ Business Rejected', 'We\'re sorry. Your business \"Liyag\" has been rejected.', 0, '2025-07-23 06:53:27'),
(45, 32, '🛍️ Business Submission Received', 'Thank you for submitting \"ff\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-23 06:58:48'),
(46, 32, '❌ Business Rejected', 'We\'re sorry. Your business \"ff\" has been rejected.', 0, '2025-07-23 06:59:06'),
(47, 32, '🛍️ Business Submission Received', 'Thank you for submitting \"Balisong\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-23 06:59:39'),
(48, 32, '✅ Business Approved!', 'Congratulations! Your business \"Balisong\" has been approved.', 0, '2025-07-23 06:59:46'),
(49, 32, '🛍️ Business Submission Received', 'Thank you for submitting \"Batangan Pasalubong\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-25 17:47:33'),
(51, 33, 'Welcome to Liyag Batangan!', 'Thank you for registering! Start exploring local delicacies and offers today.', 0, '2025-07-25 19:18:05'),
(52, 33, '🛍️ Business Submission Received', 'Thank you for submitting \"Black\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-29 17:04:15'),
(53, 33, '🛍️ Business Submission Received', 'Thank you for submitting \"Coffee\". Your business is under review. We\'ll notify you once it\'s approved.', 0, '2025-07-29 17:05:11'),
(54, 33, '🛍️ Business Submission Received', 'Thank you for submitting \"Bagx\". Your business is under review.', 0, '2025-07-29 19:22:16'),
(55, 33, '🛍️ Business Submission Received', 'Thank you for submitting \"Lomi\". Your business is under review.', 0, '2025-07-29 19:22:52'),
(56, 33, '❌ Business Rejected', 'We\'re sorry. Your business \"Lomi\" has been rejected.', 0, '2025-07-29 19:48:57'),
(57, 33, '❌ Business Rejected', 'We\'re sorry. Your business \"Bagx\" has been rejected.', 0, '2025-07-29 19:49:03'),
(58, 34, 'Welcome to Liyag Batangan!', 'Thank you for registering! Start exploring local delicacies and offers today.', 0, '2025-07-30 00:57:06'),
(59, 33, '🛍️ Business Submission Received', 'Thank you for submitting \"Coffeee\". Your business is under review.', 0, '2025-07-30 01:07:14'),
(61, 33, '✅ Business Approved!', 'Congratulations! Your business \"Black\" has been approved.', 0, '2025-07-30 07:37:48'),
(62, 33, '✅ Business Approved!', 'Congratulations! Your business \"Coffeee\" has been approved.', 0, '2025-07-30 07:39:27'),
(63, 36, 'Welcome to Liyag Batangan!', 'Thank you for registering! Start exploring local delicacies and offers today.', 0, '2025-07-30 08:21:06');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `order_status` enum('Pending','Processing','Shipped','Delivered','Cancelled') DEFAULT 'Pending',
  `payment_status` enum('Paid','Unpaid','Refunded') DEFAULT 'Unpaid',
  `order_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_app`
--

CREATE TABLE `order_app` (
  `order_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `contact` varchar(50) DEFAULT NULL,
  `total_price` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_app`
--

INSERT INTO `order_app` (`order_id`, `user_id`, `name`, `address`, `contact`, `total_price`, `created_at`) VALUES
(8, 32, 'Gilbert Saludaga', 'Arturo Tanco Drive, Balintawak, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 968 307 4206', 1500.00, '2025-07-25 15:46:11'),
(9, 32, 'Gilbert Saludaga', 'Arturo Tanco Drive, Balintawak, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 968 307 4206', 1500.00, '2025-07-25 15:51:50'),
(10, 32, 'Gilbert Saludaga', 'Arturo Tanco Drive, Balintawak, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 968 307 4206', 1500.00, '2025-07-25 15:52:01'),
(11, 32, 'Gilbert Saludaga', 'Arturo Tanco Drive, Balintawak, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 968 307 4206', 1500.00, '2025-07-25 15:52:01'),
(12, 32, 'Gilbert Saludaga', 'Arturo Tanco Drive, Balintawak, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 968 307 4206', 500.00, '2025-07-25 15:52:15'),
(13, 32, 'Gilbert Saludaga', 'Arturo Tanco Drive, Balintawak, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 968 307 4206', 500.00, '2025-07-25 15:53:22'),
(14, 32, 'Gilbert Saludaga', 'Arturo Tanco Drive, Balintawak, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 968 307 4206', 800.00, '2025-07-25 15:53:50'),
(15, 32, 'Gilbert Saludaga', 'Arturo Tanco Drive, Balintawak, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 968 307 4206', 800.00, '2025-07-25 16:19:32'),
(16, 32, 'Gilbert Saludaga', 'Arturo Tanco Drive, Balintawak, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 968 307 4206', 400.00, '2025-07-25 16:21:23'),
(17, 32, 'Gilbert Saludaga', '6, Poblacion, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 968 307 4206', 1400.00, '2025-07-25 20:02:54'),
(18, 32, 'Gilbert Saludaga', '6, Poblacion, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 968 307 4206', 1000.00, '2025-07-25 20:03:17'),
(19, 35, 'Alexandra Añonuevo', 'Batangas State University Claro M. Recto Campus, Arturo Tanco Drive, Marauoy, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 951 965 7113', 380.00, '2025-07-30 06:29:07'),
(20, 34, 'Christian Luis Hiwatig', 'Batangas State University Claro M. Recto Campus, Arturo Tanco Drive, Marauoy, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 960 271 8018', 250.00, '2025-07-30 07:35:41'),
(21, 36, 'Aries Asi', 'Batangas State University Claro M. Recto Campus, Arturo Tanco Drive, Marauoy, Lipa, Batangas, Calabarzon, 4217, Philippines', '+63 960 271 8018', 550.00, '2025-07-30 08:22:28');

-- --------------------------------------------------------

--
-- Table structure for table `order_item`
--

CREATE TABLE `order_item` (
  `order_item_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_item`
--

INSERT INTO `order_item` (`order_item_id`, `order_id`, `product_id`, `quantity`, `price`) VALUES
(1, 13, 23, 1, 500.00),
(2, 14, 21, 4, 200.00),
(3, 15, 21, 4, 200.00),
(4, 16, 21, 2, 200.00),
(5, 17, 30, 4, 350.00),
(6, 18, 26, 4, 250.00),
(7, 19, 25, 1, 130.00),
(8, 19, 34, 1, 250.00),
(9, 20, 32, 1, 250.00),
(10, 21, 36, 1, 120.00),
(11, 21, 32, 1, 250.00),
(12, 21, 33, 1, 180.00);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `order_item_id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment_methods`
--

CREATE TABLE `payment_methods` (
  `method_id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment_method_details`
--

CREATE TABLE `payment_method_details` (
  `method_detail_id` int(11) NOT NULL,
  `method_id` int(11) DEFAULT NULL,
  `provider_name` varchar(100) DEFAULT NULL,
  `account_number` varchar(100) DEFAULT NULL,
  `additional_info` text DEFAULT NULL,
  `added_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `stock_quantity` int(11) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `status` enum('Active','Inactive','OutOfStock','Discontinued') DEFAULT 'Active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `vendor_id`, `category_id`, `name`, `description`, `price`, `stock_quantity`, `image_url`, `status`, `created_at`, `updated_at`) VALUES
(25, 21, 1, 'Tablea de Batangas', 'Pure, unsweetened chocolate tablets made from local cacao beans, perfect for hot chocolate (sikwate).', 130.00, 99, 'uploads/products/prod_6883c43b8c7bc_1000002969.jpg', 'Active', '2025-07-25 17:51:55', '2025-07-30 06:29:07'),
(26, 21, 1, 'Buko Pie', 'A classic Filipino delicacy with a distinct Batangas presence.', 250.00, 196, 'uploads/products/prod_6883c4c7c507e_1000002971.jpg', 'Active', '2025-07-25 17:54:15', '2025-07-25 20:03:17'),
(27, 21, 1, 'Beef Tapa', 'Marinated beef tapa, a breakfast staple, made from local Batangas beef.', 280.00, 100, 'uploads/products/prod_6883c5ad2d137_1000002972.jpg', 'Active', '2025-07-25 17:58:05', '2025-07-25 17:58:05'),
(28, 21, 3, 'Embroidered Barong Tagalog/Baro\\\'t Saya Miniatures', 'Small, decorative versions of the traditional Filipino attire, showcasing Taal\\\'s famous embroidery.', 180.00, 500, 'uploads/products/prod_6883c630031ff_1000002973.jpg', 'Active', '2025-07-25 18:00:16', '2025-07-25 18:00:16'),
(29, 21, 3, 'Handcrafted Balisong/Fan Replicas', 'Miniature, safe replicas of the iconic Batangas balisong (butterfly knife) or beautifully crafted hand fans.', 200.00, 500, 'uploads/products/prod_6883c6b03a2b2_1000002974.jpg', 'Active', '2025-07-25 18:02:24', '2025-07-25 18:02:24'),
(30, 21, 3, '\\\"Ala Eh!\\\" T-shirts', 'Merchandise featuring the famous Batangueño colloquialism \\\"Ala Eh!\\\"', 350.00, 196, 'uploads/products/prod_6883c72bab59a_1000002975.jpg', 'Active', '2025-07-25 18:04:27', '2025-07-25 20:02:54'),
(31, 21, 3, 'Local Artisan Pottery/Ceramics', 'Small, decorative or functional pottery pieces from local Batangas potters.', 300.00, 200, 'uploads/products/prod_6883c7973db11_1000002976.jpg', 'Active', '2025-07-25 18:06:15', '2025-07-25 18:06:15'),
(32, 21, 2, 'Kapeng Barako (Ground/Beans)', 'The strong, aromatic coffee varietal, a staple of Batangas.', 250.00, 498, 'uploads/products/prod_6883c81163bae_1000002977.jpg', 'Active', '2025-07-25 18:08:17', '2025-07-30 08:22:28'),
(33, 21, 2, 'Batangas Brewed Tea Blends', 'Locally sourced herbal or fruit-infused teas unique to the region (e.g., calamansi ginger tea blend).', 180.00, 99, 'uploads/products/prod_6883c88f2944c_1000002978.jpg', 'Active', '2025-07-25 18:10:23', '2025-07-30 08:22:28'),
(34, 21, 2, 'Tsokolate Ah (Traditional Hot Chocolate Mix)', 'A ready-to-mix powder or concentrated paste for making authentic Filipino hot chocolate.', 250.00, 299, 'uploads/products/prod_6883c8fb780ce_1000002979.jpg', 'Active', '2025-07-25 18:12:11', '2025-07-30 06:29:07'),
(36, 34, 2, 'Vietnamese', 'Drip-based Coffee', 120.00, 9, 'uploads/products/prod_6889ccc9c7760_1000021199.jpg', 'Active', '2025-07-30 07:42:01', '2025-07-30 08:22:28'),
(37, 21, 1, 'Lomu', 'Lomi', 50.00, 100, 'uploads/products/prod_6889d6ba7c0e2_1000002967.jpg', 'Active', '2025-07-30 08:24:26', '2025-07-30 08:24:26');

-- --------------------------------------------------------

--
-- Table structure for table `product_categories`
--

CREATE TABLE `product_categories` (
  `category_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_categories`
--

INSERT INTO `product_categories` (`category_id`, `name`, `description`) VALUES
(1, 'Food', 'Food products like snacks, delicacies, etc.'),
(2, 'Beverages', 'Drinks and local refreshments.'),
(3, 'Souvenirs', 'Gifts and keepsakes from Batangas.');

-- --------------------------------------------------------

--
-- Table structure for table `product_reviews`
--

CREATE TABLE `product_reviews` (
  `review_id` int(11) NOT NULL,
  `product_id` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `report_id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `report_type` enum('Sales','Engagement','Inventory') DEFAULT NULL,
  `report_content` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `shopping_cart`
--

CREATE TABLE `shopping_cart` (
  `cart_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `transaction_id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `transaction_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `payment_method_id` int(11) DEFAULT NULL,
  `amount_paid` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `user_type` enum('User','Vendor') NOT NULL DEFAULT 'User',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `profile_picture` varchar(255) DEFAULT NULL,
  `otp_code` varchar(6) DEFAULT NULL,
  `otp_expiry` datetime DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `token_expires_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `email`, `password`, `phone_number`, `address`, `user_type`, `created_at`, `profile_picture`, `otp_code`, `otp_expiry`, `token`, `token_expires_at`) VALUES
(1, NULL, NULL, '$2y$10$ptuTeOq0RidOgWNvD9wBCOfAzQy7Gc.L2qbngjDtZwM.7AkJTUSCO', NULL, NULL, 'User', '2025-06-24 23:23:47', NULL, NULL, NULL, NULL, NULL),
(2, NULL, NULL, '$2y$10$Uq9ldAXJX89WMQTdIqpLWe.wGmG2SxygfEhQPF3vQHFJP/M6jDqt.', NULL, NULL, 'User', '2025-06-24 23:24:08', NULL, NULL, NULL, NULL, NULL),
(3, 'gilbs', 'gilbs@email.com', '$2y$10$TpxQ.DH3rh.ALB3zMhRCNODZkCJZZHR/WwiH25RZhuPxlD0MlGd1m', '094324234434', '831231', 'User', '2025-06-24 23:26:30', NULL, NULL, NULL, NULL, NULL),
(4, 'gilbs', 'gilbsssss@email.com', '$2y$10$hdACHibda5FYADw20GfjNOLl2P2QkJinWcrxF82yr/3FZCo2DThuq', '0912121', '121', 'User', '2025-06-24 23:48:58', NULL, NULL, NULL, NULL, NULL),
(5, 'euli', 'gils@email.com', '$2y$10$.OpDgKNSKj3okeELVZ8eS..FCHbte6KdIkVJrSqRIPyLxboQSShxy', '098753946464548', 'qwert', 'Vendor', '2025-07-01 07:18:41', 'profile_1751471691_6675.jpg', NULL, NULL, NULL, NULL),
(6, 'Ayessa Enderez', 'ayessa@email.com', '$2y$10$pDE4SCWzW1NeoHFLULNsuO2qcA.Vf95jG48X43A.fp7Ur0n9UgAj6', '09271182541', 'Latag,Lipa City', 'User', '2025-07-01 07:20:16', NULL, NULL, NULL, NULL, NULL),
(7, 'ashton lemmor', 'lemmor@email.com', '$2y$10$o8Snb0gGktwlP.rxTCZ45eKn8/Fc8PTzLbqO2L81oaRk3o/3nwXaa', '09602714274', 'Banaba, Padre Garcia', 'User', '2025-07-01 07:31:39', NULL, NULL, NULL, NULL, NULL),
(8, 'Gilbert', 'gilbs01@gmail.com', '$2y$10$tYLJo64wRAcDsWq0nVP2zO2yIwPSL2/mq7s/BRSfo008Wk5N5gAoO', '09173633', 'bahay ko', 'User', '2025-07-01 08:37:48', NULL, NULL, NULL, NULL, NULL),
(9, 'CHRISTIAN LUIS', 'luis@email.com', '$2y$10$lDf/vY8xervr3Qglrs/KDOHhVfXTBkM9b2cUNdPp1S0CVZ.TMUYhS', '09602718018', 'hehejwj', 'User', '2025-07-01 08:42:15', NULL, NULL, NULL, NULL, NULL),
(10, 'loy', 'l@gmail.com', '$2y$10$C/WWGfHPXGkrzezcDAzEmO8r1GQBwFKq0ILZm24dWGmETrecf5cB2', '898988', 'hdjd', 'User', '2025-07-01 09:03:06', NULL, NULL, NULL, NULL, NULL),
(11, 'Euli', 'euli.ganda@gmail.com', '$2y$10$1zBn/2YSvEQQmkT048Ss..BqIWOz4vUXa/KOKaWJGJYbJLSnUlr2G', '09373736277272', 'San Pablo', 'User', '2025-07-01 14:49:02', NULL, NULL, NULL, NULL, NULL),
(12, 'euli', 'euli@gmail.com', '$2y$10$.wC7e6XUUdtjLcOZZthxB.pDqJJy9.zCnIp.x.vCnmn7e8iRXUAnC', '096830722', 'San Pablo', 'User', '2025-07-01 17:11:17', NULL, NULL, NULL, NULL, NULL),
(13, 'my euli', 'euliganda@gmail.com', '$2y$10$aW9GQCwSJlWqUycTrjYvFOjft1ngasRPhoMzy8tOB6xbujOJypqfK', '02928826', 'hwywywyw', 'Vendor', '2025-07-02 17:13:43', 'profile_1751476580_3110.jpg', NULL, NULL, NULL, NULL),
(14, 'ganda', 'ganda@gmail.com', '$2y$10$taNQwhDCKOBt2o1KGmuHiOS9o89gGKQf.5xPwwvZDc3uGaoxGebgu', '092625252', 'gsgsvsvdvd', 'User', '2025-07-02 20:10:55', 'profile_1751487103_3826.jpg', NULL, NULL, NULL, NULL),
(15, 'Gilbert Saludaga', 'gilbs09@gmail.com', '$2y$10$TddJ5Mcrb4wgBbjTpONrVusKNusHleRzPXBhaKv.ua3ESQ22p8h7.', '09683074206', 'Lipa', 'User', '2025-07-03 14:00:19', 'profile_1751551271_6000.jpg', NULL, NULL, NULL, NULL),
(17, 'gilbert', 'sikret', '$2y$10$2I3Yg76wC8iHD9bOR3NGheltZa7BDSJCk26pXZ7d4Pzdv5m4tdTRO', '07262820', 'Brgy', 'Vendor', '2025-07-04 17:41:53', 'profile_1751650982_8967.png', NULL, NULL, NULL, NULL),
(18, 'Erol Jake Anillo', 'anillo123@gmail.com', '$2y$10$bdAZgNucK/QyWxa0999CJubvullrDq0gCpwtf6uq1Ral1Q/V7ieWi', '0999111326748', 'sa tabi st. tanauan batangas', 'Vendor', '2025-07-05 12:18:47', 'profile_1751717969_4272.jpg', NULL, NULL, NULL, NULL),
(19, '', '', '$2y$10$9tF8BAJzeJGgLYzJdXkEduIKkpJm0htUIOq7lOkzawrm8KoXR6EzC', '', '', 'User', '2025-07-08 06:57:10', NULL, NULL, NULL, NULL, NULL),
(21, 'Gilbert', 'gilbert@gmail.com', '$2y$10$V80v5ua./ms8XFo9RAJ7pOPe/ADyGR7PwdIAqC4jGwFpElDxL5Ex6', '094324234434', '123', 'User', '2025-07-08 10:18:38', NULL, NULL, NULL, NULL, NULL),
(24, 'GIlbert Saludagaa', 'gilbertsaludaga9@gmail.com', '$2y$10$s.Whx6Nwa62Hjbdar8v1Du0w5sRzlL1vr8Mej.uPAnaSkWQ6jXXgO', '09683074202', 'Mabini Homes, 7, Poblacion, Lipa, Batangas, Calabarzon, 4217, Philippines', 'User', '2025-07-08 19:48:09', 'uploads/686fcc741014e_484049131_1276403020105363_8520198193198002078_n.jpg', NULL, NULL, NULL, NULL),
(25, 'hilss', 'hils@email.com', '$2y$10$Lo3hps4eKQJo3pgECcaz4OwE.VpVZKXmVNT4Bo.yD7DZcv44tQ4eO', '+639683074206', 'qrtw', 'User', '2025-07-15 14:14:33', NULL, NULL, NULL, NULL, NULL),
(32, 'Gilbert Saludaga', 'gilbertsaludaga89@gmail.com', '46bec0d1ffac9ef849cd6f5827d37aa8429e1260982488e8dd14df0b32b843da', '+63 968 307 4206', 'Lipa City Grand Terminal, Lipa City Grand Terminal (UV Express), Balintawak, Lipa, Batangas, Calabarzon, 4217, Philippines', 'Vendor', '2025-07-16 04:25:23', 'profile_1753813811_6601.webp', '441476', '2025-07-29 20:38:43', NULL, NULL),
(33, 'Flor Saludaga', 'florsaludaga1968@gmail.com', '9402f5e7d24f0a786bfb270fd0b695cd4520311c4195c98d895a3b81b1e516c5', '+63 961 880 3530', '6, Poblacion, Lipa, Batangas, Calabarzon, 4217, Philippines', 'Vendor', '2025-07-25 19:18:05', 'profile_1753841024_1093.webp', '147695', '2025-07-29 20:44:37', NULL, NULL),
(34, 'Christian Luis Hiwatig', 'christian.loowis@gmail.com', '04e92d7920d707fdc4594109105406aea3383c0295efa31507c8a705742f4ded', '+63 960 271 8018', 'Batangas State University Claro M. Recto Campus, Arturo Tanco Drive, Marauoy, Lipa, Batangas, Calabarzon, 4217, Philippines', 'User', '2025-07-30 00:57:06', NULL, NULL, NULL, NULL, NULL),
(35, 'Alexandra Añonuevo', 'alexandraannonuevo@gmail.com', 'b00b2139ef336e0db552e8129c8a35e5e77452d62007bb21d7ebb2cc18edd730', '+63 951 965 7113', 'Batangas State University Claro M. Recto Campus, Arturo Tanco Drive, Marauoy, Lipa, Batangas, Calabarzon, 4217, Philippines', 'User', '2025-07-30 06:27:05', NULL, NULL, NULL, NULL, NULL),
(36, 'Aries Asi', 'ariescanubasasi@gmail.com', '7272f69f53ed53b664bacb18823893482e25bf2051d33e9aafea9fc7e22f1a9d', '+63 960 271 8018', 'Batangas State University Claro M. Recto Campus, Arturo Tanco Drive, Marauoy, Lipa, Batangas, Calabarzon, 4217, Philippines', 'User', '2025-07-30 08:21:06', NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_tokens`
--

CREATE TABLE `user_tokens` (
  `user_id` int(11) NOT NULL,
  `token` varchar(64) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_tokens`
--

INSERT INTO `user_tokens` (`user_id`, `token`, `created_at`) VALUES
(32, '660a98180c9bf2a3244bb689f6ff9417bb291684a812cf57d69584c4948a125c', '2025-07-30 15:18:34');

-- --------------------------------------------------------

--
-- Table structure for table `vendor_account`
--

CREATE TABLE `vendor_account` (
  `vendor_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `business_name` varchar(100) DEFAULT NULL,
  `business_address` text DEFAULT NULL,
  `business_description` text DEFAULT NULL,
  `logo_url` varchar(255) DEFAULT NULL,
  `registration_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `verification_document` varchar(255) DEFAULT NULL,
  `status` enum('Pending','Approved','Rejected') DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vendor_account`
--

INSERT INTO `vendor_account` (`vendor_id`, `user_id`, `business_name`, `business_address`, `business_description`, `logo_url`, `registration_date`, `verification_document`, `status`) VALUES
(21, 32, 'Batangan Pasalubong', 'V. Malabanan Street, 4, Poblacion, Lipa, Batangas, Calabarzon, 4217, Philippines', 'Batangan Pasalubong is your one-stop destination for the finest local treats and treasures from Batangas. Proudly showcasing the province’s rich culture and flavors, we offer a curated selection of authentic pasalubong items—from classic delicacies like kapeng barako, panutsa, tamales, and sinaing na tulingan to handcrafted souvenirs and artisanal goods. Whether you\\\'re a traveler, a balikbayan, or a local supporter, Batangan Pasalubong brings you closer to home with every bite and keepsake.', 'uploads/business_logos/6883c335abc59_1000002968.jpg', '2025-07-25 16:00:00', 'uploads/business_documents/6883c335abc5e_1000002967.jpg', 'Approved'),
(25, 33, 'Coffee', 'M. K. Lina Street, San Sebastian, Lipa, Batangas, Calabarzon, 4217, Philippines', 'Coffee', 'uploads/business_logos/6888ff4732f4b_1000002979.jpg', '2025-07-29 16:00:00', 'uploads/business_documents/6888ff4732f51_1000002979.jpg', 'Pending'),
(33, 33, 'Lomi', 'BDO, C. M. Recto Avenue, 4, Poblacion, Lipa, Batangas, Calabarzon, 4217, Philippines', 'black lome', 'uploads/business_logos/68891f8ce1068_1000003037.png', '2025-07-29 16:00:00', 'uploads/business_documents/68891f8ce106e_1000003039.png', 'Rejected'),
(34, 33, 'Batangas Harvest', 'Batangas State University Claro M. Recto Campus, Arturo Tanco Drive, Marauoy, Lipa, Batangas, Calabarzon, 4217, Philippines', 'simple', 'uploads/business_logos/688970423e526_1000003042.jpg', '2025-07-29 16:00:00', 'uploads/business_documents/688970423e576_1000003042.jpg', 'Approved');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_account`
--
ALTER TABLE `admin_account`
  ADD PRIMARY KEY (`admin_id`);

--
-- Indexes for table `cart_item`
--
ALTER TABLE `cart_item`
  ADD PRIMARY KEY (`cart_item_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`cart_item_id`),
  ADD KEY `cart_id` (`cart_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `customer_account`
--
ALTER TABLE `customer_account`
  ADD PRIMARY KEY (`customer_id`);

--
-- Indexes for table `delivery`
--
ALTER TABLE `delivery`
  ADD PRIMARY KEY (`delivery_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `email_verification`
--
ALTER TABLE `email_verification`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `order_app`
--
ALTER TABLE `order_app`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `order_item`
--
ALTER TABLE `order_item`
  ADD PRIMARY KEY (`order_item_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`order_item_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD PRIMARY KEY (`method_id`);

--
-- Indexes for table `payment_method_details`
--
ALTER TABLE `payment_method_details`
  ADD PRIMARY KEY (`method_detail_id`),
  ADD KEY `method_id` (`method_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `vendor_id` (`vendor_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `product_categories`
--
ALTER TABLE `product_categories`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`report_id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Indexes for table `shopping_cart`
--
ALTER TABLE `shopping_cart`
  ADD PRIMARY KEY (`cart_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_tokens`
--
ALTER TABLE `user_tokens`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `vendor_account`
--
ALTER TABLE `vendor_account`
  ADD PRIMARY KEY (`vendor_id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cart_item`
--
ALTER TABLE `cart_item`
  MODIFY `cart_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `cart_item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delivery`
--
ALTER TABLE `delivery`
  MODIFY `delivery_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_app`
--
ALTER TABLE `order_app`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `order_item`
--
ALTER TABLE `order_item`
  MODIFY `order_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `order_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `payment_methods`
--
ALTER TABLE `payment_methods`
  MODIFY `method_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payment_method_details`
--
ALTER TABLE `payment_method_details`
  MODIFY `method_detail_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `product_categories`
--
ALTER TABLE `product_categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `product_reviews`
--
ALTER TABLE `product_reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `report_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `shopping_cart`
--
ALTER TABLE `shopping_cart`
  MODIFY `cart_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `transaction_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `vendor_account`
--
ALTER TABLE `vendor_account`
  MODIFY `vendor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin_account`
--
ALTER TABLE `admin_account`
  ADD CONSTRAINT `admin_account_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `cart_item`
--
ALTER TABLE `cart_item`
  ADD CONSTRAINT `cart_item_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_ibfk_1` FOREIGN KEY (`cart_id`) REFERENCES `shopping_cart` (`cart_id`),
  ADD CONSTRAINT `cart_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`);

--
-- Constraints for table `customer_account`
--
ALTER TABLE `customer_account`
  ADD CONSTRAINT `customer_account_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `delivery`
--
ALTER TABLE `delivery`
  ADD CONSTRAINT `delivery_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer_account` (`customer_id`);

--
-- Constraints for table `order_app`
--
ALTER TABLE `order_app`
  ADD CONSTRAINT `order_app_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `order_item`
--
ALTER TABLE `order_item`
  ADD CONSTRAINT `order_item_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order_app` (`order_id`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`);

--
-- Constraints for table `payment_method_details`
--
ALTER TABLE `payment_method_details`
  ADD CONSTRAINT `payment_method_details_ibfk_1` FOREIGN KEY (`method_id`) REFERENCES `payment_methods` (`method_id`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `vendor_account` (`vendor_id`),
  ADD CONSTRAINT `products_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `product_categories` (`category_id`);

--
-- Constraints for table `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD CONSTRAINT `product_reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `product_reviews_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customer_account` (`customer_id`);

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin_account` (`admin_id`);

--
-- Constraints for table `shopping_cart`
--
ALTER TABLE `shopping_cart`
  ADD CONSTRAINT `shopping_cart_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer_account` (`customer_id`);

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`);

--
-- Constraints for table `user_tokens`
--
ALTER TABLE `user_tokens`
  ADD CONSTRAINT `user_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `vendor_account`
--
ALTER TABLE `vendor_account`
  ADD CONSTRAINT `vendor_account_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `vendor_account_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
