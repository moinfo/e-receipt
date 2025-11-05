<?php
/**
 * Get Pending Users Endpoint (Admin Only)
 * E-Receipt Management System
 * GET /api/admin/users/pending.php
 */

// Error handling
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

// Set headers
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
    if (!file_exists('../../config/session.php')) {
        throw new Exception('Session configuration file not found');
    }
    require_once '../../config/session.php';

    if (!file_exists('../../config/database.php')) {
        throw new Exception('Database configuration file not found');
    }
    require_once '../../config/database.php';

    if (!file_exists('../../models/User.php')) {
        throw new Exception('User model file not found');
    }
    require_once '../../models/User.php';

    // Check if user is logged in and is admin
    requireAdmin();

    // Get database connection
    $database = new Database();
    $db = $database->getConnection();

    if (!$db) {
        throw new Exception('Database connection failed');
    }

    // Create User object
    $user = new User($db);

    // Get pending users
    $pending_users = $user->getPendingUsers();

    if ($pending_users === false) {
        throw new Exception('Failed to retrieve pending users');
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Pending users retrieved successfully',
        'data' => $pending_users,
        'count' => count($pending_users)
    ]);

} catch (Exception $e) {
    // Log error
    error_log('Pending Users API Error: ' . $e->getMessage());

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'An error occurred while retrieving pending users',
        'error' => $e->getMessage(),
        'debug' => [
            'file' => basename(__FILE__),
            'line' => __LINE__
        ]
    ]);
}
