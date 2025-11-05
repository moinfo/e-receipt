<?php
/**
 * Get All Users Endpoint (Admin Only)
 * E-Receipt Management System
 * GET /api/admin/users/all.php
 */

header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

session_start();

require_once '../../config/database.php';
require_once '../../models/User.php';

// Check if user is logged in and is admin
if (!isset($_SESSION['user_id']) || !$_SESSION['logged_in'] || !$_SESSION['is_admin']) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Access denied. Admin privileges required.']);
    exit;
}

// Get database connection
$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit;
}

// Create User object
$user = new User($db);

// Get status filter from query params
$status_filter = isset($_GET['status']) ? $_GET['status'] : null;

// Get all users
$all_users = $user->getAllUsers($status_filter);

http_response_code(200);
echo json_encode([
    'success' => true,
    'message' => 'Users retrieved successfully',
    'data' => $all_users,
    'count' => count($all_users)
]);
