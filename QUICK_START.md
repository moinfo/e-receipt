# E-Receipt System - Quick Start Guide ⚡

## 5-Minute Setup

### Step 1: Start XAMPP
```bash
# Open XAMPP Control Panel
# Click "Start" for Apache
# Click "Start" for MySQL
```

### Step 2: Create Database
1. Open browser → `http://localhost/phpmyadmin`
2. Click "New" (left sidebar)
3. Database name: `ereceipt_db`
4. Collation: `utf8mb4_unicode_ci`
5. Click "Create"

### Step 3: Import Database
1. Select `ereceipt_db` (left sidebar)
2. Click "Import" tab
3. Click "Choose File"
4. Select: `/Applications/XAMPP/xamppfiles/htdocs/e-receipt/database/schema.sql`
5. Click "Go" → Wait for success
6. Click "Choose File" again
7. Select: `/Applications/XAMPP/xamppfiles/htdocs/e-receipt/database/seed.sql`
8. Click "Go" → Wait for success

### Step 4: Set Permissions
```bash
# Mac/Linux:
mkdir -p /Applications/XAMPP/xamppfiles/htdocs/e-receipt/api/uploads/receipts
chmod -R 777 /Applications/XAMPP/xamppfiles/htdocs/e-receipt/api/uploads/

# Windows:
# Right-click api/uploads folder → Properties → Security
# Add "Everyone" with Full Control
```

### Step 5: Access the System
```
URL: http://localhost/e-receipt/web/
```

### Step 6: Login as Admin
```
Username: admin
Password: admin123
```

**⚠️ IMPORTANT: Change the admin password immediately!**

---

## Testing the System

### Test User Registration:
1. Click "Register"
2. Fill in all fields
3. Choose a secret question and answer
4. Click "Register"
5. You'll see "Pending approval" message

### Test Admin Approval:
1. Login as admin
2. Click "Pending Users"
3. Click "Approve" for the new user
4. User can now login

### Test Receipt Upload:
1. Logout admin
2. Login as the approved user
3. Click "Upload Receipt"
4. Select a bank
5. Drag & drop or click to upload an image
6. Fill optional fields (amount, description)
7. Click "Upload Receipt"

### Test Receipt History:
1. Click "History"
2. View your uploaded receipts
3. Try searching and filtering
4. Click "View" to see receipt details

### Test Admin Features:
1. Logout and login as admin
2. View Dashboard → See statistics
3. Click "All Receipts" → See all user receipts
4. Test search and filters

---

## Default Accounts

### Admin Account:
```
Username: admin
Password: admin123
Full Name: System Administrator
```

### Sample Users (from seed.sql):
```
Username: johndoe
Password: password123
Status: Approved

Username: janesmith
Password: password123
Status: Approved

Username: bobwilson
Password: password123
Status: Pending

Username: alicebrown
Password: password123
Status: Pending
```

---

## Troubleshooting

### "Database connection failed"
```bash
# Check MySQL is running in XAMPP
# Verify database exists: ereceipt_db
# Check api/config/database.php credentials
```

### "Cannot upload files"
```bash
# Check folder exists: api/uploads/receipts/
# Check permissions: chmod -R 777 api/uploads/
# Check PHP settings in php.ini:
upload_max_filesize = 10M
post_max_size = 10M
```

### "Page not found"
```bash
# Check Apache is running
# Verify URL: http://localhost/e-receipt/web/
# Check files are in correct location
```

### "Login not working"
```bash
# Check user status is 'approved' in database
# Clear browser cookies/cache
# Verify PHP sessions are enabled
```

---

## Quick Commands

### View Database Tables:
```sql
USE ereceipt_db;
SHOW TABLES;

-- View users
SELECT id, username, full_name, status FROM users;

-- View receipts
SELECT r.id, u.username, b.bank_name, r.upload_date
FROM receipts r
JOIN users u ON r.user_id = u.id
JOIN banks b ON r.bank_id = b.id;

-- View pending users
SELECT id, username, full_name, created_at
FROM users
WHERE status = 'pending';
```

### Change Admin Password:
```sql
-- Generate new hash (use PHP)
-- Then update:
UPDATE users
SET password_hash = '$2y$10$YOUR_NEW_HASH_HERE'
WHERE username = 'admin';
```

### Add New Bank:
```sql
INSERT INTO banks (bank_name, bank_code, status)
VALUES ('Your Bank Name', 'BANK_CODE', 'active');
```

### Approve User Manually:
```sql
UPDATE users
SET status = 'approved',
    approved_at = NOW(),
    approved_by = 1
WHERE username = 'username_here';
```

---

## File Locations

```
Database:
/Applications/XAMPP/xamppfiles/htdocs/e-receipt/database/

Backend API:
/Applications/XAMPP/xamppfiles/htdocs/e-receipt/api/

Web Pages:
/Applications/XAMPP/xamppfiles/htdocs/e-receipt/web/

Uploaded Receipts:
/Applications/XAMPP/xamppfiles/htdocs/e-receipt/api/uploads/receipts/

Configuration:
/Applications/XAMPP/xamppfiles/htdocs/e-receipt/api/config/database.php
```

---

## Next Steps

1. ✅ Change admin password
2. ✅ Test all features
3. ✅ Add your banks to the database
4. ✅ Create user accounts
5. ✅ Start uploading receipts

---

## Need Help?

📖 **Full Documentation**: See `README.md`
🔧 **Installation Guide**: See `INSTALLATION.md`
📊 **Project Status**: See `PROJECT_STATUS.md`
✅ **Completion Summary**: See `COMPLETION_SUMMARY.md`

---

**Status**: ✅ Ready to Use!
**Version**: 3.0
**Support**: Check documentation files
