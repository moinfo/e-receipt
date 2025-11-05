<?php
/**
 * User Login Endpoint
 * E-Receipt Management System
 * POST /api/auth/login.php
 */

// For credentials to work, we need to specify the exact origin, not *
$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/session.php';
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
if (empty($data->username) || empty($data->password)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Username and password are required'
    ]);
    exit;
}

// Check if user exists
$user->username = $data->username;

if (!$user->usernameExists()) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid username or password'
    ]);
    exit;
}

// Verify password
if (!password_verify($data->password, $user->password_hash)) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid username or password'
    ]);
    exit;
}

// Check account status
if ($user->status === 'pending') {
    http_response_code(403);
    echo json_encode([
        'success' => false,
        'message' => 'Your account is pending admin approval. Please wait for approval.',
        'status' => 'pending'
    ]);
    exit;
}

if ($user->status === 'rejected') {
    http_response_code(403);
    echo json_encode([
        'success' => false,
        'message' => 'Your account has been rejected. Please contact the administrator.',
        'status' => 'rejected'
    ]);
    exit;
}

// Account is approved - create session
$_SESSION['user_id'] = $user->id;
$_SESSION['username'] = $user->username;
$_SESSION['full_name'] = $user->full_name;
$_SESSION['is_admin'] = $user->is_admin;
$_SESSION['logged_in'] = true;

http_response_code(200);
echo json_encode([
    'success' => true,
    'message' => 'Login successful',
    'data' => [
        'user_id' => $user->id,
        'username' => $user->username,
        'full_name' => $user->full_name,
        'phone' => $user->phone,
        'is_admin' => (bool)$user->is_admin,
        'session_id' => session_id()
    ]
]);
