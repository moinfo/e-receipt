-- ==========================================
-- Migration: Add Receipt Approval Workflow
-- Description: Adds approval status and admin approval tracking to receipts
-- Date: 2025
-- ==========================================

-- Modify receipts table to add approval status
ALTER TABLE `receipts`
MODIFY COLUMN `status` enum('pending','approved','rejected','deleted') NOT NULL DEFAULT 'pending';

-- Add columns for approval tracking
ALTER TABLE `receipts`
ADD COLUMN `approved_by` int(11) DEFAULT NULL AFTER `status`,
ADD COLUMN `approved_at` timestamp NULL DEFAULT NULL AFTER `approved_by`,
ADD COLUMN `rejection_reason` text DEFAULT NULL AFTER `approved_at`,
ADD KEY `idx_approved_by` (`approved_by`),
ADD CONSTRAINT `fk_receipts_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

-- Update existing receipts to 'approved' status (for backwards compatibility)
UPDATE `receipts` SET `status` = 'approved' WHERE `status` = 'active';
