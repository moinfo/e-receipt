<?php
/**
 * Get All Receipts Endpoint (Admin Only)
 * E-Receipt Management System
 * GET /api/admin/receipts.php?status=all|pending|approved|rejected
 */

$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET');
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

// Create Receipt object
$receipt = new Receipt($db);

// Get status filter from query parameter
$status_filter = isset($_GET['status']) ? $_GET['status'] : 'all';

// Validate status filter
$valid_statuses = ['all', 'pending', 'approved', 'rejected'];
if (!in_array($status_filter, $valid_statuses)) {
    $status_filter = 'all';
}

// Get receipts based on filter
$receipts = $receipt->getAllWithStatus($status_filter);

http_response_code(200);
echo json_encode([
    'success' => true,
    'message' => 'Receipts retrieved successfully',
    'data' => $receipts,
    'filter' => $status_filter,
    'count' => count($receipts)
]);
