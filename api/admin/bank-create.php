<?php
/**
 * Create Bank Endpoint (Admin Only)
 * E-Receipt Management System
 * POST /api/admin/bank-create.php
 */

$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

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
if (empty($data->bank_name)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Bank name is required'
    ]);
    exit;
}

// Create Bank object
$bank = new Bank($db);
$bank->bank_name = $data->bank_name;
$bank->bank_code = isset($data->bank_code) ? $data->bank_code : null;
$bank->status = isset($data->status) ? $data->status : 'active';

// Create bank
if ($bank->create()) {
    http_response_code(201);
    echo json_encode([
        'success' => true,
        'message' => 'Bank created successfully',
        'data' => [
            'id' => $bank->id,
            'bank_name' => $bank->bank_name,
            'bank_code' => $bank->bank_code,
            'status' => $bank->status
        ]
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to create bank'
    ]);
}
