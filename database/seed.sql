-- E-Receipt Management System Seed Data
-- Version: 1.0.0
-- Created: 2025-11-05
-- This file contains sample data for testing and development

USE ereceipt_db;

SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================
-- Seed Users
-- Password for all users: password123
-- Admin password: admin123
-- ==========================================
INSERT INTO `users` (`id`, `full_name`, `phone`, `username`, `password_hash`, `secret_question`, `secret_answer_hash`, `is_admin`, `status`, `created_at`, `approved_at`, `approved_by`) VALUES
(1, 'System Administrator', '+1234567890', 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'What is your favorite color?', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, 'approved', NOW(), NOW(), NULL),
(2, 'John Doe', '+1234567891', 'johndoe', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'What is your pet name?', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 0, 'approved', NOW(), NOW(), 1),
(3, 'Jane Smith', '+1234567892', 'janesmith', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'What is your birth city?', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 0, 'approved', NOW(), NOW(), 1),
(4, 'Bob Wilson', '+1234567893', 'bobwilson', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'What is your favorite food?', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 0, 'pending', NOW(), NULL, NULL),
(5, 'Alice Brown', '+1234567894', 'alicebrown', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'What is your mother maiden name?', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 0, 'pending', NOW(), NULL, NULL);

-- ==========================================
-- Seed Banks
-- Common banks for testing
-- ==========================================
INSERT INTO `banks` (`id`, `bank_name`, `bank_code`, `status`, `created_at`) VALUES
(1, 'Bank of America', 'BOA', 'active', NOW()),
(2, 'Chase Bank', 'CHASE', 'active', NOW()),
(3, 'Wells Fargo', 'WF', 'active', NOW()),
(4, 'Citibank', 'CITI', 'active', NOW()),
(5, 'US Bank', 'USB', 'active', NOW()),
(6, 'PNC Bank', 'PNC', 'active', NOW()),
(7, 'TD Bank', 'TD', 'active', NOW()),
(8, 'Capital One', 'CAPONE', 'active', NOW()),
(9, 'HSBC', 'HSBC', 'active', NOW()),
(10, 'Barclays', 'BARC', 'active', NOW());

-- ==========================================
-- Seed Receipts (for approved users only)
-- Note: These are sample entries. In production, receipt_image_path should point to actual files
-- ==========================================
INSERT INTO `receipts` (`id`, `user_id`, `bank_id`, `receipt_image_path`, `receipt_number`, `amount`, `description`, `upload_date`, `status`) VALUES
(1, 2, 1, 'uploads/receipts/sample_receipt_1.jpg', 'RCP001', 150.00, 'Grocery shopping payment', NOW() - INTERVAL 5 DAY, 'active'),
(2, 2, 2, 'uploads/receipts/sample_receipt_2.jpg', 'RCP002', 75.50, 'Restaurant bill payment', NOW() - INTERVAL 4 DAY, 'active'),
(3, 2, 3, 'uploads/receipts/sample_receipt_3.jpg', 'RCP003', 200.00, 'Online purchase payment', NOW() - INTERVAL 3 DAY, 'active'),
(4, 3, 1, 'uploads/receipts/sample_receipt_4.jpg', 'RCP004', 450.00, 'Utility bill payment', NOW() - INTERVAL 2 DAY, 'active'),
(5, 3, 4, 'uploads/receipts/sample_receipt_5.jpg', 'RCP005', 125.75, 'Gas station payment', NOW() - INTERVAL 1 DAY, 'active'),
(6, 2, 5, 'uploads/receipts/sample_receipt_6.jpg', 'RCP006', 89.99, 'Pharmacy purchase', NOW(), 'active');

-- ==========================================
-- Seed Activity Logs
-- ==========================================
INSERT INTO `activity_logs` (`user_id`, `action`, `description`, `ip_address`, `created_at`) VALUES
(1, 'LOGIN', 'Admin logged in', '127.0.0.1', NOW() - INTERVAL 1 HOUR),
(2, 'LOGIN', 'User logged in', '127.0.0.1', NOW() - INTERVAL 2 HOUR),
(1, 'APPROVE_USER', 'Approved user: johndoe', '127.0.0.1', NOW() - INTERVAL 3 HOUR),
(1, 'APPROVE_USER', 'Approved user: janesmith', '127.0.0.1', NOW() - INTERVAL 3 HOUR),
(2, 'UPLOAD_RECEIPT', 'Uploaded receipt to Bank of America', '127.0.0.1', NOW() - INTERVAL 5 DAY),
(2, 'UPLOAD_RECEIPT', 'Uploaded receipt to Chase Bank', '127.0.0.1', NOW() - INTERVAL 4 DAY),
(3, 'UPLOAD_RECEIPT', 'Uploaded receipt to Bank of America', '127.0.0.1', NOW() - INTERVAL 2 DAY);

SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================
-- Success message
-- ==========================================
SELECT 'E-Receipt Seed Data Inserted Successfully!' AS message;
SELECT
    'Default Admin Credentials:' AS info,
    'Username: admin' AS username,
    'Password: admin123' AS password,
    'IMPORTANT: Change password after first login!' AS warning;
