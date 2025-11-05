<?php
/**
 * Fix Admin Password Script
 * This will set the admin password to: admin123
 * Access: http://localhost/e-receipt/fix-admin-password.php
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Fix Admin Password</h1>";
echo "<hr>";

// Database configuration
$host = 'localhost';
$dbname = 'ereceipt_db';
$user = 'root';
$pass = '';

// Connect to database
try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✅ Connected to database successfully<br><br>";
} catch(PDOException $e) {
    die("❌ Database connection failed: " . $e->getMessage());
}

// Generate correct password hash for "admin123"
$admin_password = 'admin123';
$admin_hash = password_hash($admin_password, PASSWORD_BCRYPT);

echo "<strong>Updating admin password...</strong><br>";
echo "New password will be: <strong>admin123</strong><br><br>";

// Update admin user password
try {
    $stmt = $conn->prepare("UPDATE users SET password_hash = :password_hash WHERE username = 'admin'");
    $stmt->bindParam(':password_hash', $admin_hash);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        echo "✅ <strong style='color: green;'>Admin password updated successfully!</strong><br><br>";
    } else {
        echo "⚠️ <strong style='color: orange;'>Admin user not found or password already set</strong><br><br>";

        // Check if admin user exists
        $stmt = $conn->query("SELECT id, username, full_name FROM users WHERE username = 'admin'");
        $admin = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$admin) {
            echo "❌ Admin user does not exist in database<br>";
            echo "Creating admin user...<br>";

            // Create admin user
            $stmt = $conn->prepare("INSERT INTO users (full_name, phone, username, password_hash, secret_question, secret_answer_hash, is_admin, status, created_at, approved_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())");

            $full_name = 'System Administrator';
            $phone = '+1234567890';
            $username = 'admin';
            $secret_question = 'What is your favorite color?';
            $secret_answer_hash = password_hash('blue', PASSWORD_BCRYPT);
            $is_admin = 1;
            $status = 'approved';

            $stmt->execute([
                $full_name,
                $phone,
                $username,
                $admin_hash,
                $secret_question,
                $secret_answer_hash,
                $is_admin,
                $status
            ]);

            echo "✅ <strong style='color: green;'>Admin user created successfully!</strong><br><br>";
        }
    }
} catch(PDOException $e) {
    die("❌ Error updating password: " . $e->getMessage());
}

// Verify the update
echo "<h2>Verification</h2>";
try {
    $stmt = $conn->query("SELECT id, username, full_name, is_admin, status FROM users WHERE username = 'admin'");
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($admin) {
        echo "Admin user details:<br>";
        echo "- ID: " . $admin['id'] . "<br>";
        echo "- Username: <strong>" . $admin['username'] . "</strong><br>";
        echo "- Full Name: " . $admin['full_name'] . "<br>";
        echo "- Is Admin: " . ($admin['is_admin'] ? 'Yes' : 'No') . "<br>";
        echo "- Status: " . $admin['status'] . "<br>";
        echo "<br>";

        // Test the password
        $stmt = $conn->query("SELECT password_hash FROM users WHERE username = 'admin'");
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if (password_verify('admin123', $result['password_hash'])) {
            echo "✅ <strong style='color: green;'>Password verification successful!</strong><br>";
            echo "You can now login with:<br>";
            echo "- Username: <strong>admin</strong><br>";
            echo "- Password: <strong>admin123</strong><br>";
        } else {
            echo "❌ <strong style='color: red;'>Password verification failed!</strong><br>";
        }
    } else {
        echo "❌ Admin user not found!<br>";
    }
} catch(PDOException $e) {
    echo "Error during verification: " . $e->getMessage();
}

echo "<hr>";
echo "<h2>Next Steps</h2>";
echo "1. Go to login page: <a href='web/login.html'>Login Here</a><br>";
echo "2. Use credentials: admin / admin123<br>";
echo "3. After successful login, <strong>delete this fix-admin-password.php file</strong><br>";

?>

<style>
    body {
        font-family: Arial, sans-serif;
        max-width: 800px;
        margin: 50px auto;
        padding: 20px;
        background-color: #f5f5f5;
    }
    h1 { color: #333; }
    h2 {
        color: #555;
        background-color: #fff;
        padding: 10px;
        border-left: 4px solid #F59E0B;
        margin-top: 20px;
    }
    hr { margin: 20px 0; }
    a {
        color: #F59E0B;
        text-decoration: none;
        font-weight: bold;
    }
    a:hover {
        text-decoration: underline;
    }
</style>
