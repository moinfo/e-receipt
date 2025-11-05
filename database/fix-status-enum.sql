-- ==========================================
-- Fix Receipt Status Enum
-- Description: Update status enum to include approval workflow values
-- ==========================================

-- First, update existing 'active' records to 'approved'
UPDATE `receipts` SET `status` = 'approved' WHERE `status` = 'active';

-- Now modify the status column to use new enum values
ALTER TABLE `receipts`
MODIFY COLUMN `status` enum('pending','approved','rejected','deleted') NOT NULL DEFAULT 'pending';
