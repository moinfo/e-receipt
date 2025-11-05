# Receipt Approval Workflow Migration

## Overview
This migration adds an approval workflow for receipts. Admins must now approve receipts before they are considered active in the system.

## Changes Made

### 1. Database Schema Changes
- Modified `receipts.status` enum to include: `pending`, `approved`, `rejected`, `deleted`
- Added `approved_by` column (foreign key to users table)
- Added `approved_at` timestamp column
- Added `rejection_reason` text column

### 2. New API Endpoints
- `/api/admin/receipts.php` - Get all receipts with status filtering
- `/api/admin/approve-receipt.php` - Approve or reject receipts

### 3. Updated Features
- Receipt uploads now set status to `pending` by default
- Admin receipts page now shows status badges
- Admin can approve/reject receipts with one click
- Status filtering (All, Pending, Approved, Rejected)
- Rejection reason can be provided

## Migration Steps

### Step 1: Backup Database
**IMPORTANT**: Always backup your database before running migrations!

```bash
mysqldump -u root -p ereceipt_db > backup_before_approval_migration.sql
```

### Step 2: Run Migration Script
Open phpMyAdmin or MySQL command line and run the migration file:

```bash
mysql -u root -p ereceipt_db < database/migration-add-receipt-approval.sql
```

**OR** in phpMyAdmin:
1. Open phpMyAdmin
2. Select `ereceipt_db` database
3. Click on "SQL" tab
4. Copy and paste the contents of `database/migration-add-receipt-approval.sql`
5. Click "Go" to execute

### Step 3: Verify Migration
Run this query to verify the changes:

```sql
DESCRIBE receipts;
```

You should see the new columns:
- `status` enum('pending','approved','rejected','deleted')
- `approved_by` int(11)
- `approved_at` timestamp
- `rejection_reason` text

### Step 4: Check Existing Data
All existing receipts have been automatically updated to `approved` status for backwards compatibility.

```sql
SELECT status, COUNT(*) as count FROM receipts GROUP BY status;
```

## Usage

### For Users
1. Upload receipt as normal
2. Receipt status will be "Pending" until admin approves
3. User can view their pending receipts in their dashboard

### For Admins
1. Go to "All Receipts" page
2. Click "Pending" filter to see receipts awaiting approval
3. Click "Approve" or "Reject" buttons
4. For rejection, optionally provide a reason
5. Use status filters to view approved/rejected receipts

## Features

### Admin Dashboard Statistics
- Now shows pending receipts count
- Shows approved receipts count
- Shows rejected receipts count

### Status Badges
- 🟡 **Pending**: Yellow badge - awaiting admin approval
- 🟢 **Approved**: Green badge - approved by admin
- 🔴 **Rejected**: Red badge - rejected by admin

### Approval Tracking
- System tracks who approved/rejected each receipt
- System tracks when approval/rejection occurred
- Rejection reasons are stored and can be viewed

## File Upload Changes

### Supported File Types
- JPG, PNG, GIF images
- **NEW**: PDF files

### Maximum File Size
- Increased from 5MB to 10MB

## API Changes

### New Endpoints

#### GET `/api/admin/receipts.php`
Get all receipts with optional status filter.

**Query Parameters:**
- `status` (optional): `all`, `pending`, `approved`, `rejected`

**Response:**
```json
{
  "success": true,
  "data": [...],
  "filter": "pending",
  "count": 5
}
```

#### POST `/api/admin/approve-receipt.php`
Approve or reject a receipt (admin only).

**Request Body:**
```json
{
  "receipt_id": 123,
  "action": "approve" | "reject",
  "reason": "Optional rejection reason"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Receipt approved successfully"
}
```

### Modified Endpoints

#### POST `/api/receipts/upload.php`
- Now sets status to `pending` instead of `active`
- Accepts PDF files in addition to images
- Maximum file size increased to 10MB

## Rollback Instructions

If you need to rollback this migration:

```sql
-- Restore from backup
mysql -u root -p ereceipt_db < backup_before_approval_migration.sql
```

## Support

If you encounter any issues:
1. Check Apache error logs: `/Applications/XAMPP/xamppfiles/logs/error_log`
2. Check PHP error logs
3. Verify database connection
4. Ensure session is working properly

## Testing Checklist

- [ ] Migration ran successfully
- [ ] Existing receipts show as "approved"
- [ ] New receipt uploads show as "pending"
- [ ] Admin can view pending receipts
- [ ] Admin can approve receipts
- [ ] Admin can reject receipts with reason
- [ ] Status filters work correctly
- [ ] Statistics show correct counts
- [ ] PDF upload works
- [ ] File size up to 10MB works
