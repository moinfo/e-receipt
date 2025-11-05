<?php
/**
 * Get All Banks Endpoint
 * E-Receipt Management System
 * GET /api/banks/list.php
 */

header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/database.php';
require_once '../models/Bank.php';

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

// Get all active banks
$banks = $bank->getAll();

http_response_code(200);
echo json_encode([
    'success' => true,
    'message' => 'Banks retrieved successfully',
    'data' => $banks,
    'count' => count($banks)
]);
