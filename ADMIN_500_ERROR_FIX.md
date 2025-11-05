# Admin Statistics 500 Error - Troubleshooting Guide

## Error Description

**Symptoms:**
- Admin dashboard fails to load statistics
- Browser console shows:
  ```
  API Error: SyntaxError: Unexpected token '<', "<!DOCTYPE "... is not valid JSON
  ```
- Request to `https://e-receipt.lerumaenterprises.co.tz/api/admin/statistics.php` returns:
  ```
  Status Code: 500 Internal Server Error
  ```

## Why This Happens

When the server returns a 500 error, it sends an HTML error page instead of JSON. JavaScript tries to parse this HTML as JSON and fails with the "Unexpected token '<'" error because HTML starts with `<!DOCTYPE`.

## Common Causes

### 1. Session Issues
**Problem:** Session not started or session configuration error
**Check:** Make sure you're logged in as admin

### 2. File Path Issues
**Problem:** Required files not found or in wrong location
**Check:** All files exist in correct directories

### 3. Database Connection Failed
**Problem:** Wrong credentials or database not accessible
**Check:** Database configuration in `api/config/database.php`

### 4. .htaccess Blocking
**Problem:** Server .htaccess configuration blocking PHP execution
**Check:** Remove or simplify .htaccess files

### 5. PHP Version
**Problem:** Server running PHP < 7.4
**Check:** PHP version via phpinfo() or cPanel

### 6. PHP Syntax Error
**Problem:** Syntax error in PHP code causing fatal error
**Check:** PHP error logs

## Step-by-Step Debugging

### Step 1: Use the Test Endpoint

I've created a diagnostic tool that will show you exactly what's failing:

**URL:** `https://e-receipt.lerumaenterprises.co.tz/api/admin/test-statistics.php`

Visit this URL in your browser. It will show:
```
Statistics API Test
-------------------
Step 1: Testing file paths...
Step 2: Loading configuration files...
Step 3: Testing session...
Step 4: Testing database connection...
Step 5: Testing User statistics...
Step 6: Testing Receipt statistics...
Step 7: Testing JSON output...
```

Each step will show ✓ (success) or ✗ (failure) with error details.

### Step 2: Check Login Status

The test will show if you're logged in. If not:

1. Go to: `https://e-receipt.lerumaenterprises.co.tz/web/admin/login.html`
2. Login with: `admin / admin123`
3. Then run the test again

### Step 3: Check Error Logs

**In cPanel:**
1. Go to `Metrics` → `Errors`
2. Look for recent 500 errors
3. Check the error message

**In File Manager:**
1. Navigate to `public_html/`
2. Look for `error_log` file
3. View last 20 lines for clues

**Via SSH:**
```bash
tail -20 ~/public_html/error_log
```

### Step 4: Verify File Structure

All these files must exist on production:

```
e-receipt/
├── api/
│   ├── config/
│   │   ├── database.php
│   │   └── session.php
│   ├── models/
│   │   ├── User.php
│   │   └── Receipt.php
│   └── admin/
│       ├── statistics.php
│       └── test-statistics.php
```

**How to check (cPanel):**
1. Open File Manager
2. Navigate to each directory
3. Verify all files are present

### Step 5: Check Database Configuration

**File:** `api/config/database.php`

Verify these settings match your production database:
```php
private $host = "localhost";           // Usually localhost
private $db_name = "your_db_name";     // Your database name
private $username = "your_db_user";    // Your database username
private $password = "your_db_pass";    // Your database password
```

**Test database connection:**
1. Open phpMyAdmin in cPanel
2. Try to browse the `users` and `receipts` tables
3. If you can see data, database is working

### Step 6: Check .htaccess Files

**.htaccess files that might cause issues:**
- `/e-receipt/.htaccess`
- `/e-receipt/api/.htaccess`
- `/e-receipt/api/admin/.htaccess`

**Solution:** Temporarily rename them:
```bash
# Via SSH
mv api/.htaccess api/.htaccess.bak
mv api/admin/.htaccess api/admin/.htaccess.bak

# Or via cPanel File Manager: Right-click → Rename
```

Then test if statistics API works. If it does, the .htaccess was the problem.

### Step 7: Check PHP Version

**Via cPanel:**
1. Go to `Software` → `Select PHP Version`
2. Should show PHP 7.4 or higher
3. If lower, select PHP 7.4 or 8.0

**Required PHP extensions:**
- ✓ mysqli
- ✓ pdo_mysql
- ✓ session
- ✓ json

### Step 8: Enable Error Display (Temporarily)

**Create:** `api/admin/debug-statistics.php`

```php
<?php
// Enable error display
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Load the real statistics file
require_once 'statistics.php';
```

Visit: `https://e-receipt.lerumaenterprises.co.tz/api/admin/debug-statistics.php`

This will show PHP errors directly in the browser.

## Solutions by Error Type

### Error: "Session configuration file not found"
```bash
# Solution: Check file exists
ls -la api/config/session.php

# If missing, re-upload from local
```

### Error: "Database connection failed"
```bash
# Solution: Check credentials
nano api/config/database.php

# Verify:
# - Database name is correct
# - Username has permissions
# - Password is correct
```

### Error: "Failed to retrieve user statistics"
```sql
-- Solution: Check if users table exists
SHOW TABLES LIKE 'users';

-- Check table structure
DESCRIBE users;

-- Test query manually
SELECT COUNT(*) FROM users;
```

### Error: "Call to undefined function"
```bash
# Solution: Check PHP extensions
php -m | grep -i pdo
php -m | grep -i mysqli

# Or in cPanel: Software → Select PHP Version → Extensions
```

## Quick Fixes

### Fix 1: Reset File Permissions
```bash
cd /home/username/public_html/e-receipt
find api/ -type f -name "*.php" -exec chmod 644 {} \;
find api/ -type d -exec chmod 755 {} \;
```

### Fix 2: Clear PHP Opcache
```bash
# Via SSH
php -r 'opcache_reset();'

# Or in cPanel: PHP Version → Restart
```

### Fix 3: Restart PHP-FPM
```bash
# In cPanel: MultiPHP Manager → Service Actions → Restart
```

### Fix 4: Remove All .htaccess Files
```bash
cd /home/username/public_html/e-receipt
find . -name ".htaccess" -type f -delete
```

Then test if it works without .htaccess.

## Updated statistics.php Features

The new version includes:

1. **Better error handling:**
   - Try-catch blocks around all operations
   - Detailed error messages
   - File existence checks before loading

2. **JSON error responses:**
   - Always returns JSON (never HTML)
   - Includes error message
   - Includes debug information

3. **Preflight handling:**
   - Handles OPTIONS requests
   - CORS headers set correctly

4. **Error logging:**
   - Logs errors to PHP error log
   - Easier to debug server-side

## Testing After Upload

1. **Upload new files:**
   - `api/admin/statistics.php` (updated with error handling)
   - `api/admin/test-statistics.php` (new diagnostic tool)

2. **Run diagnostic test:**
   ```
   Visit: https://e-receipt.lerumaenterprises.co.tz/api/admin/test-statistics.php
   ```

3. **Check each step:**
   - All steps should show ✓
   - If any show ✗, note the error message

4. **Test real API:**
   ```
   Visit: https://e-receipt.lerumaenterprises.co.tz/api/admin/statistics.php
   ```
   Should return JSON like:
   ```json
   {
     "success": true,
     "message": "Statistics retrieved successfully",
     "data": {
       "users": {...},
       "receipts": {...}
     }
   }
   ```

5. **Test admin dashboard:**
   - Login at `/web/admin/login.html`
   - Go to `/web/admin/dashboard.html`
   - Statistics should load without errors

## Still Not Working?

If none of the above works, gather this information:

1. **PHP Error Log:**
   ```bash
   tail -50 ~/public_html/error_log
   ```

2. **Apache Error Log:**
   ```bash
   tail -50 /var/log/apache2/error.log
   # or
   tail -50 /var/log/httpd/error_log
   ```

3. **Test endpoint output:**
   - Take screenshot of test-statistics.php output
   - Note which step fails

4. **PHP Info:**
   - Create `phpinfo.php`:
     ```php
     <?php phpinfo(); ?>
     ```
   - Visit it, check PHP version and extensions

5. **Server specs:**
   - Hosting provider name
   - PHP version
   - MySQL version
   - Any custom configurations

## Prevention

To avoid this error in the future:

1. **Always test locally first** before uploading to production
2. **Keep backups** of working configuration files
3. **Monitor error logs** regularly
4. **Use the test endpoint** after any changes
5. **Document** any custom server configurations

---

**Version:** 3.4
**Date:** 2025-11-06
**Files Needed:**
- `api/admin/statistics.php` (updated)
- `api/admin/test-statistics.php` (new)
