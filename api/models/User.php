<?php
/**
 * User Model
 * E-Receipt Management System
 * Handles all user-related database operations
 */

class User {
    private $conn;
    private $table = 'users';

    // User properties
    public $id;
    public $full_name;
    public $phone;
    public $username;
    public $password_hash;
    public $secret_question;
    public $secret_answer_hash;
    public $is_admin;
    public $status;
    public $created_at;
    public $approved_at;
    public $approved_by;

    /**
     * Constructor
     */
    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Create new user (registration)
     * @return bool
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . "
                  (full_name, phone, username, password_hash, secret_question, secret_answer_hash, is_admin, status)
                  VALUES (:full_name, :phone, :username, :password_hash, :secret_question, :secret_answer_hash, :is_admin, :status)";

        $stmt = $this->conn->prepare($query);

        // Sanitize inputs
        $this->full_name = htmlspecialchars(strip_tags($this->full_name));
        $this->phone = htmlspecialchars(strip_tags($this->phone));
        $this->username = htmlspecialchars(strip_tags($this->username));
        $this->secret_question = htmlspecialchars(strip_tags($this->secret_question));

        // Bind parameters
        $stmt->bindParam(':full_name', $this->full_name);
        $stmt->bindParam(':phone', $this->phone);
        $stmt->bindParam(':username', $this->username);
        $stmt->bindParam(':password_hash', $this->password_hash);
        $stmt->bindParam(':secret_question', $this->secret_question);
        $stmt->bindParam(':secret_answer_hash', $this->secret_answer_hash);
        $stmt->bindParam(':is_admin', $this->is_admin);
        $stmt->bindParam(':status', $this->status);

        if ($stmt->execute()) {
            $this->id = $this->conn->lastInsertId();
            return true;
        }

        return false;
    }

    /**
     * Check if username exists
     * @return bool
     */
    public function usernameExists() {
        $query = "SELECT id, full_name, phone, username, password_hash, secret_question, secret_answer_hash,
                  is_admin, status, created_at, approved_at, approved_by
                  FROM " . $this->table . " WHERE username = :username LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':username', $this->username);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->id = $row['id'];
            $this->full_name = $row['full_name'];
            $this->phone = $row['phone'];
            $this->username = $row['username'];
            $this->password_hash = $row['password_hash'];
            $this->secret_question = $row['secret_question'];
            $this->secret_answer_hash = $row['secret_answer_hash'];
            $this->is_admin = $row['is_admin'];
            $this->status = $row['status'];
            $this->created_at = $row['created_at'];
            $this->approved_at = $row['approved_at'];
            $this->approved_by = $row['approved_by'];

            return true;
        }

        return false;
    }

    /**
     * Get user by ID
     * @return bool
     */
    public function getById() {
        $query = "SELECT id, full_name, phone, username, is_admin, status, created_at, approved_at, approved_by
                  FROM " . $this->table . " WHERE id = :id LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->id = $row['id'];
            $this->full_name = $row['full_name'];
            $this->phone = $row['phone'];
            $this->username = $row['username'];
            $this->is_admin = $row['is_admin'];
            $this->status = $row['status'];
            $this->created_at = $row['created_at'];
            $this->approved_at = $row['approved_at'];
            $this->approved_by = $row['approved_by'];

            return true;
        }

        return false;
    }

    /**
     * Get all pending users (for admin approval)
     * @return array
     */
    public function getPendingUsers() {
        $query = "SELECT id, full_name, phone, username, created_at
                  FROM " . $this->table . "
                  WHERE status = 'pending'
                  ORDER BY created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get all users with optional filter
     * @param string $status_filter
     * @return array
     */
    public function getAllUsers($status_filter = null) {
        $query = "SELECT u.id, u.full_name, u.phone, u.username, u.is_admin, u.status,
                  u.created_at, u.approved_at, approver.username as approved_by_username
                  FROM " . $this->table . " u
                  LEFT JOIN " . $this->table . " approver ON u.approved_by = approver.id";

        if ($status_filter) {
            $query .= " WHERE u.status = :status";
        }

        $query .= " ORDER BY u.created_at DESC";

        $stmt = $this->conn->prepare($query);

        if ($status_filter) {
            $stmt->bindParam(':status', $status_filter);
        }

        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Approve user
     * @param int $admin_id
     * @return bool
     */
    public function approve($admin_id) {
        $query = "UPDATE " . $this->table . "
                  SET status = 'approved', approved_at = NOW(), approved_by = :admin_id
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(':admin_id', $admin_id);

        return $stmt->execute();
    }

    /**
     * Reject user
     * @param int $admin_id
     * @return bool
     */
    public function reject($admin_id) {
        $query = "UPDATE " . $this->table . "
                  SET status = 'rejected', approved_at = NOW(), approved_by = :admin_id
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(':admin_id', $admin_id);

        return $stmt->execute();
    }

    /**
     * Update password
     * @return bool
     */
    public function updatePassword() {
        $query = "UPDATE " . $this->table . "
                  SET password_hash = :password_hash
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(':password_hash', $this->password_hash);

        return $stmt->execute();
    }

    /**
     * Get user statistics
     * @return array
     */
    public function getStatistics() {
        $query = "SELECT
                  COUNT(*) as total_users,
                  SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_users,
                  SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved_users,
                  SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected_users,
                  SUM(CASE WHEN is_admin = 1 THEN 1 ELSE 0 END) as admin_users
                  FROM " . $this->table;

        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * Get users by status (admin function)
     * @param string $status
     * @return array
     */
    public function getUsersByStatus($status) {
        $query = "SELECT id, username, full_name, phone, is_admin, status, created_at
                  FROM " . $this->table . "
                  WHERE status = :status
                  ORDER BY created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':status', $status);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Update user by admin
     * @return bool
     */
    public function updateByAdmin() {
        $query = "UPDATE " . $this->table . "
                  SET full_name = :full_name,
                      phone = :phone,
                      is_admin = :is_admin
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        // Sanitize inputs
        $this->full_name = htmlspecialchars(strip_tags($this->full_name));
        $this->phone = htmlspecialchars(strip_tags($this->phone));

        // Bind parameters
        $stmt->bindParam(':full_name', $this->full_name);
        $stmt->bindParam(':phone', $this->phone);
        $stmt->bindParam(':is_admin', $this->is_admin);
        $stmt->bindParam(':id', $this->id);

        return $stmt->execute();
    }

    /**
     * Delete user by admin (hard delete)
     * @return bool
     */
    public function deleteByAdmin() {
        // First check if user is an admin
        $this->getById();
        if ($this->is_admin) {
            return false; // Cannot delete admin users
        }

        $query = "DELETE FROM " . $this->table . " WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);

        return $stmt->execute();
    }
}
