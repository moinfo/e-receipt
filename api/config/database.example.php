<?php
/**
 * Database Configuration - EXAMPLE FILE
 *
 * INSTRUCTIONS:
 * 1. Copy this file to database.php
 * 2. Update the credentials below with your actual database details
 * 3. Never commit database.php to version control
 *
 * For local development:
 *   - host: localhost
 *   - db_name: ereceipt_db
 *   - username: root
 *   - password: (your XAMPP/MAMP password, usually empty)
 *
 * For production:
 *   - host: localhost (or your production DB host)
 *   - db_name: your_production_database_name
 *   - username: your_production_database_user
 *   - password: your_strong_production_password
 */

class Database {
    // Database credentials - CHANGE THESE
    private $host = "localhost";
    private $db_name = "ereceipt_db";  // Change for production
    private $username = "root";         // Change for production
    private $password = "";             // Change for production
    private $conn;

    /**
     * Get database connection
     * @return PDO|null
     */
    public function getConnection() {
        $this->conn = null;

        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name,
                $this->username,
                $this->password,
                array(
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
                )
            );
        } catch(PDOException $e) {
            error_log("Database Connection Error: " . $e->getMessage());
            return null;
        }

        return $this->conn;
    }

    /**
     * Close database connection
     */
    public function closeConnection() {
        $this->conn = null;
    }
}
