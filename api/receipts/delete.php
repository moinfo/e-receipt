<?php
/**
 * Delete Receipt Endpoint
 * E-Receipt Management System
 * DELETE /api/receipts/delete.php
 */

$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: DELETE, POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/session.php';
require_once '../config/database.php';
require_once '../models/Receipt.php';

// Check if user is logged in
requireLogin();

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

// Validate receipt ID
if (empty($data->receipt_id)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Receipt ID is required']);
    exit;
}

// Create Receipt object
$receipt = new Receipt($db);
$receipt->id = $data->receipt_id;
$receipt->user_id = $_SESSION['user_id'];

// Delete receipt (soft delete)
if ($receipt->delete()) {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Receipt deleted successfully'
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to delete receipt'
    ]);
}
