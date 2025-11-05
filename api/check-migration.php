<?php
/**
 * Check if receipt approval migration is needed
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'config/database.php';

echo "<h1>Migration Status Check</h1>";
echo "<hr>";

// Get database connection
$database = new Database();
$db = $database->getConnection();

if (!$db) {
    die("Database connection failed");
}

echo "<h2>Checking receipts table structure...</h2>";

// Check if new columns exist
$query = "SHOW COLUMNS FROM receipts";
$stmt = $db->prepare($query);
$stmt->execute();
$columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

$hasApprovedBy = false;
$hasApprovedAt = false;
$hasRejectionReason = false;
$statusValues = '';

echo "<table border='1' cellpadding='10'>";
echo "<tr><th>Column</th><th>Type</th><th>Null</th><th>Key</th><th>Default</th></tr>";

foreach ($columns as $column) {
    echo "<tr>";
    echo "<td>{$column['Field']}</td>";
    echo "<td>{$column['Type']}</td>";
    echo "<td>{$column['Null']}</td>";
    echo "<td>{$column['Key']}</td>";
    echo "<td>{$column['Default']}</td>";
    echo "</tr>";

    if ($column['Field'] === 'approved_by') $hasApprovedBy = true;
    if ($column['Field'] === 'approved_at') $hasApprovedAt = true;
    if ($column['Field'] === 'rejection_reason') $hasRejectionReason = true;
    if ($column['Field'] === 'status') $statusValues = $column['Type'];
}

echo "</table>";

echo "<hr>";
echo "<h2>Migration Status:</h2>";

// Check if status enum has new values
$hasNewStatusValues = (strpos($statusValues, 'pending') !== false) &&
                      (strpos($statusValues, 'approved') !== false) &&
                      (strpos($statusValues, 'rejected') !== false);

if ($hasApprovedBy && $hasApprovedAt && $hasRejectionReason && $hasNewStatusValues) {
    echo "<p style='color: green; font-size: 1.2em;'><strong>✅ Migration fully completed!</strong></p>";
    echo "<p>All required columns exist:</p>";
    echo "<ul>";
    echo "<li>✅ approved_by</li>";
    echo "<li>✅ approved_at</li>";
    echo "<li>✅ rejection_reason</li>";
    echo "<li>✅ status enum updated with pending, approved, rejected values</li>";
    echo "</ul>";
    echo "<p><strong>Status field values:</strong> {$statusValues}</p>";
} else if ($hasApprovedBy && $hasApprovedAt && $hasRejectionReason && !$hasNewStatusValues) {
    echo "<p style='color: orange; font-size: 1.2em;'><strong>⚠️ Migration partially completed!</strong></p>";
    echo "<p>Columns exist but status enum needs updating:</p>";
    echo "<ul>";
    echo "<li>✅ approved_by</li>";
    echo "<li>✅ approved_at</li>";
    echo "<li>✅ rejection_reason</li>";
    echo "<li>❌ status enum needs new values (pending, approved, rejected)</li>";
    echo "</ul>";
    echo "<p><strong>Current status values:</strong> {$statusValues}</p>";
    echo "<hr>";
    echo "<h3>How to fix status enum:</h3>";
    echo "<ol>";
    echo "<li>Open phpMyAdmin</li>";
    echo "<li>Select 'ereceipt_db' database</li>";
    echo "<li>Click 'SQL' tab</li>";
    echo "<li>Copy the SQL from: <code>database/fix-status-enum.sql</code></li>";
    echo "<li>Paste and execute</li>";
    echo "</ol>";
} else {
    echo "<p style='color: red; font-size: 1.2em;'><strong>❌ Migration needed!</strong></p>";
    echo "<p>Missing columns:</p>";
    echo "<ul>";
    if (!$hasApprovedBy) echo "<li>❌ approved_by</li>";
    if (!$hasApprovedAt) echo "<li>❌ approved_at</li>";
    if (!$hasRejectionReason) echo "<li>❌ rejection_reason</li>";
    echo "</ul>";
    echo "<hr>";
    echo "<h3>How to run migration:</h3>";
    echo "<ol>";
    echo "<li>Open phpMyAdmin</li>";
    echo "<li>Select 'ereceipt_db' database</li>";
    echo "<li>Click 'SQL' tab</li>";
    echo "<li>Copy the SQL from: <code>database/migration-add-receipt-approval.sql</code></li>";
    echo "<li>Paste and execute</li>";
    echo "</ol>";
}

echo "<hr>";
echo "<p><a href='../web/dashboard.html'>← Back to Dashboard</a></p>";

?>

<style>
    body {
        font-family: Arial, sans-serif;
        max-width: 1000px;
        margin: 50px auto;
        padding: 20px;
        background-color: #1f1f1f;
        color: #f5f5f5;
    }
    h1 { color: #F59E0B; }
    h2 { color: #F59E0B; }
    table {
        width: 100%;
        border-collapse: collapse;
        background-color: #2d2d2d;
    }
    th {
        background-color: #F59E0B;
        color: white;
        padding: 10px;
    }
    td {
        padding: 8px;
        border: 1px solid #444;
    }
    a {
        color: #F59E0B;
        text-decoration: none;
    }
    code {
        background-color: #2d2d2d;
        padding: 2px 6px;
        border-radius: 3px;
        color: #F59E0B;
    }
</style>
