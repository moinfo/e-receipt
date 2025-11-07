<?php
/**
 * Reject User Endpoint (Admin Only)
 * E-Receipt Management System
 * POST /api/admin/users/reject.php
 */

$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once '../../config/session.php';
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

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Validate user ID
if (empty($data->user_id)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'User ID is required']);
    exit;
}

// Create User object
$user = new User($db);
$user->id = $data->user_id;

// Reject user
if ($user->reject($_SESSION['user_id'])) {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'User rejected successfully'
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to reject user'
    ]);
}
