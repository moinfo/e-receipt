<?php
/**
 * Get User Receipt History Endpoint
 * E-Receipt Management System
 * GET /api/receipts/user-history.php
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

// Create Receipt object
$receipt = new Receipt($db);
$receipt->user_id = getCurrentUserId();

// Check if requesting today's data only (for dashboard)
$todayOnly = isset($_GET['today']) && $_GET['today'] === 'true';

// Get user receipts
if ($todayOnly) {
    $receipts = $receipt->getTodayByUser();
} else {
    $receipts = $receipt->getByUser();
}

// Get user statistics (always today for dashboard)
$stats = $receipt->getUserStatistics();

http_response_code(200);
echo json_encode([
    'success' => true,
    'message' => 'Receipts retrieved successfully',
    'data' => $receipts,
    'statistics' => $stats,
    'count' => count($receipts),
    'today_only' => $todayOnly
]);
