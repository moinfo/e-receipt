<?php
/**
 * Restore Bank Endpoint (Admin Only)
 * E-Receipt Management System
 * POST /api/admin/bank-restore.php
 */

$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/session.php';
require_once '../config/database.php';
require_once '../models/Bank.php';

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
        'message' => 'Bank ID is required'
    ]);
    exit;
}

// Create Bank object
$bank = new Bank($db);
$bank->id = $data->id;

// Get existing bank data
if (!$bank->getById()) {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Bank not found'
    ]);
    exit;
}

// Restore bank (set status to active)
$bank->status = 'active';
if ($bank->update()) {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Bank restored successfully'
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to restore bank'
    ]);
}