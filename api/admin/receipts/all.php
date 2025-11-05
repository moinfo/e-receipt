<?php
/**
 * Get All Receipts Endpoint (Admin Only)
 * E-Receipt Management System
 * GET /api/admin/receipts/all.php
 */

// Error handling
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

// Set headers
$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    // Include required files with error checking
    if (!file_exists('../../config/session.php')) {
        throw new Exception('Session configuration file not found');
    }
    require_once '../../config/session.php';

    if (!file_exists('../../config/database.php')) {
        throw new Exception('Database configuration file not found');
    }
    require_once '../../config/database.php';

    if (!file_exists('../../models/Receipt.php')) {
        throw new Exception('Receipt model file not found');
    }
    require_once '../../models/Receipt.php';

    // Check if user is logged in and is admin
    requireAdmin();

    // Get database connection
    $database = new Database();
    $db = $database->getConnection();

    if (!$db) {
        throw new Exception('Database connection failed');
    }

    // Create Receipt object
    $receipt = new Receipt($db);

    // Get pagination parameters
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 100;
    $offset = isset($_GET['offset']) ? (int)$_GET['offset'] : 0;

    // Get all receipts
    $receipts = $receipt->getAll($limit, $offset);

    if ($receipts === false) {
        throw new Exception('Failed to retrieve receipts');
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Receipts retrieved successfully',
        'data' => $receipts,
        'count' => count($receipts)
    ]);

} catch (Exception $e) {
    // Log error
    error_log('All Receipts API Error: ' . $e->getMessage());

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'An error occurred while retrieving receipts',
        'error' => $e->getMessage(),
        'debug' => [
            'file' => basename(__FILE__),
            'line' => __LINE__
        ]
    ]);
}
