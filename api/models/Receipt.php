<?php
/**
 * Receipt Model
 * E-Receipt Management System
 * Handles all receipt-related database operations
 */

class Receipt {
    private $conn;
    private $table = 'receipts';

    // Receipt properties
    public $id;
    public $user_id;
    public $bank_id;
    public $receipt_image_path;
    public $receipt_number;
    public $amount;
    public $description;
    public $upload_date;
    public $status;
    public $approved_by;
    public $approved_at;
    public $rejection_reason;

    /**
     * Constructor
     */
    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Create new receipt
     * @return bool
     */
    public function create() {
        $query = "INSERT INTO " . $this->table . "
                  (user_id, bank_id, receipt_image_path, receipt_number, amount, description, status)
                  VALUES (:user_id, :bank_id, :receipt_image_path, :receipt_number, :amount, :description, :status)";

        $stmt = $this->conn->prepare($query);

        // Sanitize inputs
        $this->receipt_image_path = htmlspecialchars(strip_tags($this->receipt_image_path));
        $this->receipt_number = htmlspecialchars(strip_tags($this->receipt_number));
        $this->description = htmlspecialchars(strip_tags($this->description));

        // Bind parameters
        $stmt->bindParam(':user_id', $this->user_id);
        $stmt->bindParam(':bank_id', $this->bank_id);
        $stmt->bindParam(':receipt_image_path', $this->receipt_image_path);
        $stmt->bindParam(':receipt_number', $this->receipt_number);
        $stmt->bindParam(':amount', $this->amount);
        $stmt->bindParam(':description', $this->description);
        $stmt->bindParam(':status', $this->status);

        if ($stmt->execute()) {
            $this->id = $this->conn->lastInsertId();
            return true;
        }

        return false;
    }

    /**
     * Get receipt by ID
     * @return bool
     */
    public function getById() {
        $query = "SELECT r.*, b.bank_name, u.username, u.full_name
                  FROM " . $this->table . " r
                  LEFT JOIN banks b ON r.bank_id = b.id
                  LEFT JOIN users u ON r.user_id = u.id
                  WHERE r.id = :id AND r.status = 'active'
                  LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->id = $row['id'];
            $this->user_id = $row['user_id'];
            $this->bank_id = $row['bank_id'];
            $this->receipt_image_path = $row['receipt_image_path'];
            $this->receipt_number = $row['receipt_number'];
            $this->amount = $row['amount'];
            $this->description = $row['description'];
            $this->upload_date = $row['upload_date'];
            $this->status = $row['status'];

            return true;
        }

        return false;
    }

    /**
     * Get all receipts for a specific user
     * @return array
     */
    public function getByUser() {
        $query = "SELECT r.*, b.bank_name, b.bank_code
                  FROM " . $this->table . " r
                  LEFT JOIN banks b ON r.bank_id = b.id
                  WHERE r.user_id = :user_id AND r.status IN ('pending', 'approved', 'rejected')
                  ORDER BY r.upload_date DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $this->user_id);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get today's receipts for a specific user (for dashboard)
     * @return array
     */
    public function getTodayByUser() {
        $query = "SELECT r.*, b.bank_name, b.bank_code
                  FROM " . $this->table . " r
                  LEFT JOIN banks b ON r.bank_id = b.id
                  WHERE r.user_id = :user_id
                  AND r.status IN ('pending', 'approved', 'rejected')
                  AND DATE(r.upload_date) = CURDATE()
                  ORDER BY r.upload_date DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $this->user_id);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get all receipts (admin function)
     * @param int $limit
     * @param int $offset
     * @return array
     */
    public function getAll($limit = 100, $offset = 0) {
        $query = "SELECT r.*, b.bank_name, b.bank_code, u.username, u.full_name, u.phone
                  FROM " . $this->table . " r
                  LEFT JOIN banks b ON r.bank_id = b.id
                  LEFT JOIN users u ON r.user_id = u.id
                  WHERE r.status = 'active'
                  ORDER BY r.upload_date DESC
                  LIMIT :limit OFFSET :offset";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get receipts with filters
     * @param array $filters
     * @return array
     */
    public function getWithFilters($filters = []) {
        $query = "SELECT r.*, b.bank_name, b.bank_code, u.username, u.full_name
                  FROM " . $this->table . " r
                  LEFT JOIN banks b ON r.bank_id = b.id
                  LEFT JOIN users u ON r.user_id = u.id
                  WHERE r.status = 'active'";

        if (isset($filters['user_id'])) {
            $query .= " AND r.user_id = :user_id";
        }

        if (isset($filters['bank_id'])) {
            $query .= " AND r.bank_id = :bank_id";
        }

        if (isset($filters['date_from'])) {
            $query .= " AND DATE(r.upload_date) >= :date_from";
        }

        if (isset($filters['date_to'])) {
            $query .= " AND DATE(r.upload_date) <= :date_to";
        }

        $query .= " ORDER BY r.upload_date DESC";

        $stmt = $this->conn->prepare($query);

        if (isset($filters['user_id'])) {
            $stmt->bindParam(':user_id', $filters['user_id']);
        }

        if (isset($filters['bank_id'])) {
            $stmt->bindParam(':bank_id', $filters['bank_id']);
        }

        if (isset($filters['date_from'])) {
            $stmt->bindParam(':date_from', $filters['date_from']);
        }

        if (isset($filters['date_to'])) {
            $stmt->bindParam(':date_to', $filters['date_to']);
        }

        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Delete receipt (soft delete)
     * @return bool
     */
    public function delete() {
        $query = "UPDATE " . $this->table . "
                  SET status = 'deleted'
                  WHERE id = :id AND user_id = :user_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(':user_id', $this->user_id);

        return $stmt->execute();
    }

    /**
     * Get receipt statistics
     * @return array
     */
    public function getStatistics() {
        $query = "SELECT
                  COUNT(*) as total_receipts,
                  SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_receipts,
                  SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved_receipts,
                  SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected_receipts,
                  COUNT(DISTINCT user_id) as total_users_uploaded,
                  COUNT(DISTINCT bank_id) as banks_used,
                  COALESCE(SUM(CASE WHEN status IN ('approved', 'pending') THEN amount ELSE 0 END), 0) as total_amount,
                  COALESCE(AVG(CASE WHEN status IN ('approved', 'pending') THEN amount ELSE NULL END), 0) as average_amount
                  FROM " . $this->table . "
                  WHERE status != 'deleted'";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * Get user receipt statistics
     * @return array
     */
    public function getUserStatistics() {
        $query = "SELECT
                  COUNT(*) as total_receipts,
                  SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_receipts,
                  SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved_receipts,
                  SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected_receipts,
                  COUNT(DISTINCT bank_id) as banks_used,
                  COALESCE(SUM(CASE WHEN status = 'approved' THEN amount ELSE 0 END), 0) as total_amount,
                  MAX(upload_date) as last_upload
                  FROM " . $this->table . "
                  WHERE user_id = :user_id
                  AND status IN ('pending', 'approved', 'rejected')
                  AND DATE(upload_date) = CURDATE()";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $this->user_id);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * Get pending receipts (admin function)
     * @return array
     */
    public function getPending() {
        $query = "SELECT r.*, b.bank_name, b.bank_code, u.username, u.full_name, u.phone
                  FROM " . $this->table . " r
                  LEFT JOIN banks b ON r.bank_id = b.id
                  LEFT JOIN users u ON r.user_id = u.id
                  WHERE r.status = 'pending'
                  ORDER BY r.upload_date ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Approve receipt (admin function)
     * @param int $admin_id
     * @return bool
     */
    public function approve($admin_id) {
        $query = "UPDATE " . $this->table . "
                  SET status = 'approved',
                      approved_by = :admin_id,
                      approved_at = NOW()
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(':admin_id', $admin_id);

        return $stmt->execute();
    }

    /**
     * Reject receipt (admin function)
     * @param int $admin_id
     * @param string $reason
     * @return bool
     */
    public function reject($admin_id, $reason = null) {
        $query = "UPDATE " . $this->table . "
                  SET status = 'rejected',
                      approved_by = :admin_id,
                      approved_at = NOW(),
                      rejection_reason = :reason
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(':admin_id', $admin_id);
        $stmt->bindParam(':reason', $reason);

        return $stmt->execute();
    }

    /**
     * Get all receipts including status filter (admin function)
     * @param string $status_filter
     * @return array
     */
    public function getAllWithStatus($status_filter = 'all') {
        $query = "SELECT r.*, b.bank_name, b.bank_code, u.username, u.full_name, u.phone,
                  admin.full_name as approved_by_name
                  FROM " . $this->table . " r
                  LEFT JOIN banks b ON r.bank_id = b.id
                  LEFT JOIN users u ON r.user_id = u.id
                  LEFT JOIN users admin ON r.approved_by = admin.id
                  WHERE 1=1";

        if ($status_filter !== 'all') {
            $query .= " AND r.status = :status";
        } else {
            $query .= " AND r.status != 'deleted'";
        }

        $query .= " ORDER BY r.upload_date DESC";

        $stmt = $this->conn->prepare($query);

        if ($status_filter !== 'all') {
            $stmt->bindParam(':status', $status_filter);
        }

        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
