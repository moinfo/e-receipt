<?php
/**
 * User Registration Endpoint
 * E-Receipt Management System
 * POST /api/auth/register.php
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
if (empty($data->full_name) || empty($data->phone) || empty($data->username) ||
    empty($data->password) || empty($data->secret_question) || empty($data->secret_answer)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'All fields are required'
    ]);
    exit;
}

// Validate username format (alphanumeric, underscore only)
if (!preg_match('/^[a-zA-Z0-9_]{3,20}$/', $data->username)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Username must be 3-20 characters (letters, numbers, underscore only)'
    ]);
    exit;
}

// Validate phone format
if (!preg_match('/^[\+]?[0-9]{10,15}$/', $data->phone)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid phone number format'
    ]);
    exit;
}

// Validate password strength (minimum 6 characters)
if (strlen($data->password) < 6) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Password must be at least 6 characters long'
    ]);
    exit;
}

// Check if username already exists
$user->username = $data->username;
if ($user->usernameExists()) {
    http_response_code(409);
    echo json_encode([
        'success' => false,
        'message' => 'Username already exists'
    ]);
    exit;
}

// Set user properties
$user->full_name = $data->full_name;
$user->phone = $data->phone;
$user->username = $data->username;
$user->password_hash = password_hash($data->password, PASSWORD_BCRYPT);
$user->secret_question = $data->secret_question;
$user->secret_answer_hash = password_hash(strtolower(trim($data->secret_answer)), PASSWORD_BCRYPT);
$user->is_admin = 0;  // Regular user
$user->status = 'pending';  // Pending admin approval

// Create user
if ($user->create()) {
    http_response_code(201);
    echo json_encode([
        'success' => true,
        'message' => 'Registration successful! Your account is pending admin approval.',
        'data' => [
            'user_id' => $user->id,
            'username' => $user->username,
            'status' => 'pending'
        ]
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Registration failed. Please try again.'
    ]);
}
