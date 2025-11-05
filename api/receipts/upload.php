<?php
/**
 * Upload Receipt Endpoint
 * E-Receipt Management System
 * POST /api/receipts/upload.php
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
require_once '../models/User.php';

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

// Validate required fields
if (empty($_POST['bank_id'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Bank selection is required']);
    exit;
}

// Check if file was uploaded
if (!isset($_FILES['receipt_image']) || $_FILES['receipt_image']['error'] !== UPLOAD_ERR_OK) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Receipt image is required']);
    exit;
}

// Validate file
$file = $_FILES['receipt_image'];
$allowed_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'application/pdf'];
$max_size = 10 * 1024 * 1024; // 10MB

// Check file type
if (!in_array($file['type'], $allowed_types)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Only JPG, PNG, GIF images and PDF files are allowed']);
    exit;
}

// Check file size
if ($file['size'] > $max_size) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'File size must not exceed 10MB']);
    exit;
}

// Create uploads directory if it doesn't exist
$upload_dir = '../uploads/receipts/';
if (!is_dir($upload_dir)) {
    mkdir($upload_dir, 0777, true);
}

// Generate unique filename
$file_extension = pathinfo($file['name'], PATHINFO_EXTENSION);
$new_filename = 'receipt_' . $_SESSION['user_id'] . '_' . time() . '_' . uniqid() . '.' . $file_extension;
$upload_path = $upload_dir . $new_filename;

// Move uploaded file
if (!move_uploaded_file($file['tmp_name'], $upload_path)) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to upload file']);
    exit;
}

// Create Receipt object
$receipt = new Receipt($db);

// Set receipt properties
$receipt->user_id = $_SESSION['user_id'];
$receipt->bank_id = $_POST['bank_id'];
$receipt->receipt_image_path = 'uploads/receipts/' . $new_filename;
$receipt->receipt_number = isset($_POST['receipt_number']) ? $_POST['receipt_number'] : null;
$receipt->amount = isset($_POST['amount']) ? $_POST['amount'] : null;
$receipt->description = isset($_POST['description']) ? $_POST['description'] : null;
$receipt->status = 'pending'; // Receipt needs admin approval

// Save receipt to database
if ($receipt->create()) {
    http_response_code(201);
    echo json_encode([
        'success' => true,
        'message' => 'Receipt uploaded successfully',
        'data' => [
            'receipt_id' => $receipt->id,
            'file_path' => $receipt->receipt_image_path
        ]
    ]);
} else {
    // Delete uploaded file if database insert fails
    if (file_exists($upload_path)) {
        unlink($upload_path);
    }

    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to save receipt']);
}
