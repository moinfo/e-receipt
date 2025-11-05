<?php
/**
 * Get System Statistics Endpoint (Admin Only)
 * E-Receipt Management System
 * GET /api/admin/statistics.php
 */

// Error handling for debugging (remove in production after fixing)
error_reporting(E_ALL);
ini_set('display_errors', 0); // Don't display, but log
ini_set('log_errors', 1);

// Set headers first before any output
$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    // Include required files with error checking
    if (!file_exists('../config/session.php')) {
        throw new Exception('Session configuration file not found');
    }
    require_once '../config/session.php';

    if (!file_exists('../config/database.php')) {
        throw new Exception('Database configuration file not found');
    }
    require_once '../config/database.php';

    if (!file_exists('../models/User.php')) {
        throw new Exception('User model file not found');
    }
    require_once '../models/User.php';

    if (!file_exists('../models/Receipt.php')) {
        throw new Exception('Receipt model file not found');
    }
    require_once '../models/Receipt.php';

    // Check if user is logged in and is admin
    requireAdmin();

    // Get database connection
    $database = new Database();
    $db = $database->getConnection();

    if (!$db) {
        throw new Exception('Database connection failed');
    }

    // Create objects
    $user = new User($db);
    $receipt = new Receipt($db);

    // Get statistics with error handling
    $user_stats = $user->getStatistics();
    if (!$user_stats) {
        throw new Exception('Failed to retrieve user statistics');
    }

    $receipt_stats = $receipt->getStatistics();
    if (!$receipt_stats) {
        throw new Exception('Failed to retrieve receipt statistics');
    }

    // Combine statistics
    $statistics = [
        'users' => $user_stats,
        'receipts' => $receipt_stats,
        'generated_at' => date('Y-m-d H:i:s')
    ];

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Statistics retrieved successfully',
        'data' => $statistics
    ]);

} catch (Exception $e) {
    // Log error
    error_log('Statistics API Error: ' . $e->getMessage());

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'An error occurred while retrieving statistics',
        'error' => $e->getMessage(),
        'debug' => [
            'file' => basename(__FILE__),
            'line' => __LINE__
        ]
    ]);
}
