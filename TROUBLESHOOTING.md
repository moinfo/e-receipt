# E-Receipt System - Troubleshooting Guide

## Database Connection Failed Error

If you're seeing "Database connection failed" on the login page, follow these steps:

### Step 1: Run the Connection Test Script

1. Open your browser
2. Go to: `http://localhost/e-receipt/test-connection.php`
3. This will check:
   - MySQL extension is loaded
   - MySQL server is running
   - Database exists
   - Tables are created
   - Admin user exists

### Step 2: Check XAMPP Status

1. Open **XAMPP Control Panel**
2. Make sure these are running (green):
   - ✅ Apache (should say "Running")
   - ✅ MySQL (should say "Running")

If MySQL is not running:
- Click the "Start" button next to MySQL
- Wait for it to turn green
- If it fails to start, click "Logs" to see the error

### Step 3: Create Database (if missing)

1. **Open phpMyAdmin**:
   - URL: `http://localhost/phpmyadmin`
   - Or click "Admin" button next to MySQL in XAMPP

2. **Create Database**:
   - Click "New" in left sidebar
   - Database name: `ereceipt_db`
   - Collation: `utf8mb4_unicode_ci`
   - Click "Create"

### Step 4: Import Database Schema

1. **In phpMyAdmin**, select `ereceipt_db` (left sidebar)

2. **Import Schema**:
   - Click "Import" tab at the top
   - Click "Choose File"
   - Navigate to: `/Applications/XAMPP/xamppfiles/htdocs/e-receipt/database/schema.sql`
   - Click "Go" at the bottom
   - Wait for "Import has been successfully finished" message

3. **Import Sample Data**:
   - Click "Import" tab again
   - Click "Choose File"
   - Navigate to: `/Applications/XAMPP/xamppfiles/htdocs/e-receipt/database/seed.sql`
   - Click "Go"
   - Wait for success message

### Step 5: Verify Tables Created

In phpMyAdmin:
- Select `ereceipt_db` database
- You should see 4 tables in the left sidebar:
  - ✅ users
  - ✅ banks
  - ✅ receipts
  - ✅ activity_logs

### Step 6: Check Database Configuration

1. Open file: `/Applications/XAMPP/xamppfiles/htdocs/e-receipt/api/config/database.php`

2. Check these settings:
   ```php
   define('DB_HOST', 'localhost');
   define('DB_NAME', 'ereceipt_db');
   define('DB_USER', 'root');
   define('DB_PASS', '');  // Leave empty if no password
   ```

3. If you have a MySQL password:
   - Change `DB_PASS` to your password
   - Example: `define('DB_PASS', 'your_password_here');`

### Step 7: Test the Login

1. Go to: `http://localhost/e-receipt/web/login.html`
2. Try logging in:
   - Username: `admin`
   - Password: `admin123`

---

## Common Issues & Solutions

### Issue 1: "MySQL Server is not running"

**Solution**:
```bash
1. Open XAMPP Control Panel
2. Click "Stop" next to MySQL (if it shows)
3. Wait 5 seconds
4. Click "Start" next to MySQL
5. Check if port 3306 is not being used by another program
```

### Issue 2: "Access denied for user 'root'@'localhost'"

**Solution**:
```bash
# You have a MySQL password set
1. Open api/config/database.php
2. Change: define('DB_PASS', 'your_mysql_password');
3. Save the file
4. Refresh the login page
```

### Issue 3: "Unknown database 'ereceipt_db'"

**Solution**:
```bash
1. Open phpMyAdmin: http://localhost/phpmyadmin
2. Click "New" in left sidebar
3. Create database named: ereceipt_db
4. Import database/schema.sql
5. Import database/seed.sql
```

### Issue 4: "Table 'ereceipt_db.users' doesn't exist"

**Solution**:
```bash
1. You didn't import the schema.sql file
2. Open phpMyAdmin
3. Select ereceipt_db database
4. Click "Import"
5. Choose database/schema.sql
6. Click "Go"
```

### Issue 5: "Cannot login - Invalid username or password"

**Solution**:
```bash
1. Make sure you imported seed.sql (contains admin user)
2. Default credentials:
   Username: admin
   Password: admin123
3. Check user status in database:
   - Open phpMyAdmin
   - Go to ereceipt_db → users table
   - Find admin user
   - Status should be "approved"
```

### Issue 6: Port 3306 Already in Use

**Solution**:
```bash
# Another MySQL instance is running
1. Stop any other MySQL services
2. Or change XAMPP MySQL port:
   - XAMPP Control Panel → Config → my.ini
   - Change port from 3306 to 3307
   - Update api/config/database.php:
     define('DB_HOST', 'localhost:3307');
```

### Issue 7: "Upload folder not writable"

**Solution**:
```bash
# Mac/Linux:
chmod -R 777 /Applications/XAMPP/xamppfiles/htdocs/e-receipt/api/uploads/

# Windows:
Right-click api/uploads folder
→ Properties → Security → Edit
→ Add "Everyone" with Full Control
```

---

## Quick Checks

### ✅ Checklist Before Login

- [ ] XAMPP Apache is running (green)
- [ ] XAMPP MySQL is running (green)
- [ ] Database `ereceipt_db` exists
- [ ] All 4 tables exist (users, banks, receipts, activity_logs)
- [ ] Admin user exists in users table
- [ ] Admin user status is "approved"
- [ ] schema.sql imported successfully
- [ ] seed.sql imported successfully
- [ ] api/uploads/receipts/ folder exists
- [ ] Folder permissions set correctly

### 🔍 Verify Database Setup

Run these SQL queries in phpMyAdmin to verify:

```sql
-- Check database exists
SHOW DATABASES LIKE 'ereceipt_db';

-- Check tables exist
USE ereceipt_db;
SHOW TABLES;

-- Check admin user
SELECT id, username, full_name, is_admin, status
FROM users
WHERE username = 'admin';

-- Check banks
SELECT COUNT(*) as bank_count FROM banks;

-- Check database structure
DESCRIBE users;
```

---

## Still Having Issues?

### Enable PHP Error Display

1. Open `/Applications/XAMPP/xamppfiles/htdocs/e-receipt/api/auth/login.php`
2. Add these lines at the very top (after `<?php`):
   ```php
   error_reporting(E_ALL);
   ini_set('display_errors', 1);
   ```
3. Try logging in again
4. You'll see detailed error messages

### Check Apache Error Log

1. XAMPP Control Panel
2. Click "Logs" button next to Apache
3. Look for recent errors
4. Share these with support if needed

### Check PHP Info

1. Create file: `/Applications/XAMPP/xamppfiles/htdocs/test.php`
2. Add content: `<?php phpinfo(); ?>`
3. Visit: `http://localhost/test.php`
4. Check if PDO MySQL is enabled

---

## After Fixing

1. ✅ Delete `test-connection.php` file (for security)
2. ✅ Clear browser cache and cookies
3. ✅ Try logging in again
4. ✅ Change admin password after first successful login

---

## Need More Help?

- Check the database/schema.sql file is not corrupted
- Make sure all files are in correct locations
- Verify XAMPP version is compatible (7.4+)
- Try restarting XAMPP completely
- Check Windows Firewall/Antivirus isn't blocking MySQL

---

**Quick Test URL**: `http://localhost/e-receipt/test-connection.php`

This will run all diagnostic tests automatically!
