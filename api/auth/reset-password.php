<?php
/**
 * Reset Password Endpoint
 * E-Receipt Management System
 * POST /api/auth/reset-password.php
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
if (empty($data->username) || empty($data->secret_answer) || empty($data->new_password)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'All fields are required'
    ]);
    exit;
}

// Validate password strength
if (strlen($data->new_password) < 6) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Password must be at least 6 characters long'
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

// Verify secret answer
if (!password_verify(strtolower(trim($data->secret_answer)), $user->secret_answer_hash)) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Incorrect answer to secret question'
    ]);
    exit;
}

// Update password
$user->password_hash = password_hash($data->new_password, PASSWORD_BCRYPT);

if ($user->updatePassword()) {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Password reset successful. You can now login with your new password.'
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Password reset failed. Please try again.'
    ]);
}
