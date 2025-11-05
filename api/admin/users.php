<?php
/**
 * User Management Endpoint (Admin Only)
 * E-Receipt Management System
 * GET /api/admin/users.php - Get all users
 */

$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/session.php';
require_once '../config/database.php';
require_once '../models/User.php';

// Check if user is logged in and is admin
requireAdmin();

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

// Get status filter
$status = isset($_GET['status']) ? $_GET['status'] : 'all';

// Get users based on status
if ($status === 'all') {
    $users = $user->getAllUsers();
} else {
    $users = $user->getUsersByStatus($status);
}

http_response_code(200);
echo json_encode([
    'success' => true,
    'message' => 'Users retrieved successfully',
    'data' => $users,
    'count' => count($users),
    'filter' => $status
]);
