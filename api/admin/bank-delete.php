<?php
/**
 * Delete Bank Endpoint (Admin Only)
 * E-Receipt Management System
 * DELETE /api/admin/bank-delete.php
 */

$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: DELETE, POST');
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

// Delete bank
if ($bank->delete()) {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Bank deleted successfully'
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to delete bank. It may be in use by receipts.'
    ]);
}
