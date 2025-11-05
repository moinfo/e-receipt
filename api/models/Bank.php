<?php
/**
 * Bank Model
 * E-Receipt Management System
 * Handles all bank-related database operations
 */

class Bank {
    private $conn;
    private $table = 'banks';

    // Bank properties
    public $id;
    public $bank_name;
    public $bank_code;
    public $status;
    public $created_at;

    /**
     * Constructor
     */
    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Get all active banks
     * @return array
     */
    public function getAll() {
        $query = "SELECT id, bank_name, bank_code, status, created_at
                  FROM " . $this->table . "
                  WHERE status = 'active'
                  ORDER BY bank_name ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get all banks including inactive (for admin)
     * @return array
     */
    public function getAllForAdmin() {
        $query = "SELECT id, bank_name, bank_code, status, created_at
                  FROM " . $this->table . "
                  ORDER BY bank_name ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get bank by ID
     * @return bool
     */
    public function getById() {
        $query = "SELECT id, bank_name, bank_code, status, created_at
                  FROM " . $this->table . "
                  WHERE id = :id LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->id = $row['id'];
            $this->bank_name = $row['bank_name'];
            $this->bank_code = $row['bank_code'];
            $this->status = $row['status'];
            $this->created_at = $row['created_at'];

            return true;
        }

        return false;
    }

    /**
     * Create new bank
     * @return bool
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . "
                  (bank_name, bank_code, status)
                  VALUES (:bank_name, :bank_code, :status)";

        $stmt = $this->conn->prepare($query);

        // Sanitize inputs
        $this->bank_name = htmlspecialchars(strip_tags($this->bank_name));
        $this->bank_code = htmlspecialchars(strip_tags($this->bank_code));

        // Bind parameters
        $stmt->bindParam(':bank_name', $this->bank_name);
        $stmt->bindParam(':bank_code', $this->bank_code);
        $stmt->bindParam(':status', $this->status);

        if ($stmt->execute()) {
            $this->id = $this->conn->lastInsertId();
            return true;
        }

        return false;
    }

    /**
     * Update bank
     * @return bool
     */
    public function update() {
        $query = "UPDATE " . $this->table . "
                  SET bank_name = :bank_name,
                      bank_code = :bank_code,
                      status = :status
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        // Sanitize inputs
        $this->bank_name = htmlspecialchars(strip_tags($this->bank_name));
        $this->bank_code = htmlspecialchars(strip_tags($this->bank_code));

        // Bind parameters
        $stmt->bindParam(':bank_name', $this->bank_name);
        $stmt->bindParam(':bank_code', $this->bank_code);
        $stmt->bindParam(':status', $this->status);
        $stmt->bindParam(':id', $this->id);

        return $stmt->execute();
    }

    /**
     * Delete bank (soft delete by changing status)
     * @return bool
     */
    public function delete() {
        $query = "UPDATE " . $this->table . "
                  SET status = 'inactive'
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);

        return $stmt->execute();
    }

    /**
     * Check if bank name exists
     * @return bool
     */
    public function bankNameExists() {
        $query = "SELECT id FROM " . $this->table . "
                  WHERE bank_name = :bank_name
                  AND id != :id LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':bank_name', $this->bank_name);
        $stmt->bindParam(':id', $this->id);
        $stmt->execute();

        return $stmt->rowCount() > 0;
    }
}
