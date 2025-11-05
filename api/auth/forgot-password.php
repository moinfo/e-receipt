<?php
/**
 * Forgot Password Endpoint
 * E-Receipt Management System
 * POST /api/auth/forgot-password.php
 */

header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/database.php';
require_once '../models/User.php';

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

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Validate required fields
if (empty($data->username)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Username is required'
    ]);
    exit;
}

// Check if user exists
$user->username = $data->username;

if (!$user->usernameExists()) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Username not found'
    ]);
    exit;
}

// Return secret question
http_response_code(200);
echo json_encode([
    'success' => true,
    'message' => 'Secret question retrieved',
    'data' => [
        'username' => $user->username,
        'secret_question' => $user->secret_question
    ]
]);
