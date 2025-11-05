<?php
/**
 * Bank Management Endpoint (Admin Only)
 * E-Receipt Management System
 * GET /api/admin/banks.php - Get all banks
 */

$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://localhost';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET');
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

// Create Bank object
$bank = new Bank($db);

// Get all banks (including inactive)
$banks = $bank->getAllForAdmin();

http_response_code(200);
echo json_encode([
    'success' => true,
    'message' => 'Banks retrieved successfully',
    'data' => $banks,
    'count' => count($banks)
]);
