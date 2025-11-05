<?php
/**
 * Delete User Endpoint (Admin Only)
 * E-Receipt Management System
 * DELETE /api/admin/user-delete.php
 */

$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: DELETE, POST');
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

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Validate required fields
if (empty($data->id)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'User ID is required'
    ]);
    exit;
}

// Prevent deleting own account
if ($data->id == getCurrentUserId()) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'You cannot delete your own account'
    ]);
    exit;
}

// Create User object
$user = new User($db);
$user->id = $data->id;

// Delete user
if ($user->deleteByAdmin()) {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'User deleted successfully'
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to delete user'
    ]);
}
