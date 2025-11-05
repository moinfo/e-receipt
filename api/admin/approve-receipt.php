<?php
/**
 * Approve/Reject Receipt Endpoint (Admin Only)
 * E-Receipt Management System
 * POST /api/admin/approve-receipt.php
 */

$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/session.php';
require_once '../config/database.php';
require_once '../models/Receipt.php';

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
if (empty($data->receipt_id) || empty($data->action)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Receipt ID and action are required'
    ]);
    exit;
}

// Validate action
if (!in_array($data->action, ['approve', 'reject'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid action. Must be "approve" or "reject"'
    ]);
    exit;
}

// Create Receipt object
$receipt = new Receipt($db);
$receipt->id = $data->receipt_id;

// Get admin ID from session
$admin_id = getCurrentUserId();

// Perform action
if ($data->action === 'approve') {
    if ($receipt->approve($admin_id)) {
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Receipt approved successfully'
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to approve receipt'
        ]);
    }
} else if ($data->action === 'reject') {
    $reason = isset($data->reason) ? $data->reason : 'No reason provided';

    if ($receipt->reject($admin_id, $reason)) {
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Receipt rejected successfully'
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to reject receipt'
        ]);
    }
}
