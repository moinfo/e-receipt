# Production Deployment & Troubleshooting Guide

## 🚨 500 Internal Server Error - Common Causes & Solutions

### Cause 1: .htaccess Issues
**Problem:** Server doesn't support .htaccess directives or mod_headers is not enabled

**Solution:**
```bash
# Option A: Remove .htaccess files (recommended for production)
rm /path/to/e-receipt/web/.htaccess
rm /path/to/e-receipt/web/admin/.htaccess
rm /path/to/e-receipt/.htaccess

# Option B: Simplify .htaccess (if you need to keep it)
# See simplified version below
```

**Simplified .htaccess for Production:**
```apache
# Minimal configuration
AddDefaultCharset UTF-8
DirectoryIndex index.html
Options -Indexes
```

---

### Cause 2: PHP Session Configuration
**Problem:** Session directory not writable or session_start() failing

**Solution:**
```php
// Check session.php has proper error handling
// Update api/config/session.php if needed
```

Check your PHP error logs at:
- cPanel: `public_html/error_log`
- Server: `/var/log/apache2/error.log` or `/var/log/httpd/error_log`

---

### Cause 3: File Permissions
**Problem:** Files/folders not readable by web server

**Solution:**
```bash
# Set correct permissions
cd /path/to/e-receipt
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;

# Make uploads directory writable
chmod 755 api/uploads
chmod 644 api/uploads/*
```

---

### Cause 4: Database Connection
**Problem:** Database credentials incorrect or database not accessible

**Solution:**
```php
// Update api/config/database.php with production credentials
private $host = "localhost";  // or your DB host
private $db_name = "your_production_db_name";
private $username = "your_db_user";
private $password = "your_db_password";
```

---

### Cause 5: PHP Version Incompatibility
**Problem:** Server running PHP < 7.4 or missing required extensions

**Solution:**
```bash
# Check PHP version
php -v

# Required: PHP 7.4 or higher
# Required extensions: mysqli, pdo_mysql, session, json
```

---

## 🔧 Step-by-Step Production Deployment

### Step 1: Prepare Files
```bash
# On your local machine, create a clean package
cd /Applications/XAMPP/xamppfiles/htdocs/e-receipt

# Remove .htaccess files for production
rm web/.htaccess
rm web/admin/.htaccess
rm .htaccess

# Create deployment package (exclude unnecessary files)
zip -r e-receipt-production.zip \
  api/ \
  web/ \
  database/ \
  index.html \
  -x "*.DS_Store" \
  -x "*/.git/*" \
  -x "*/mobile_app/*"
```

### Step 2: Upload to Server
```bash
# Using FTP/SFTP, upload to:
/public_html/e-receipt/

# Or using SSH:
scp e-receipt-production.zip user@your-server.com:/home/user/
ssh user@your-server.com
cd /home/user
unzip e-receipt-production.zip -d public_html/e-receipt/
```

### Step 3: Create Database
```sql
-- In cPanel phpMyAdmin or MySQL command line:
CREATE DATABASE your_production_db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Import schema
USE your_production_db_name;
SOURCE /path/to/database/schema.sql;
SOURCE /path/to/database/seed.sql;

-- If migration needed:
SOURCE /path/to/database/migration-add-receipt-approval.sql;
```

### Step 4: Configure Database Connection
```bash
# Edit api/config/database.php
nano public_html/e-receipt/api/config/database.php

# Update credentials:
private $host = "localhost";
private $db_name = "your_production_db_name";
private $username = "your_db_user";
private $password = "your_db_password";
```

### Step 5: Set Permissions
```bash
cd public_html/e-receipt

# Set directory permissions
find . -type d -exec chmod 755 {} \;

# Set file permissions
find . -type f -exec chmod 644 {} \;

# Make uploads directory writable
chmod 755 api/uploads
```

### Step 6: Configure PHP (if needed)
```ini
# In .htaccess or php.ini:
upload_max_filesize = 10M
post_max_size = 10M
memory_limit = 256M
max_execution_time = 300
```

### Step 7: Update API URLs in JavaScript
```javascript
// Edit web/assets/js/app.js
const API_BASE_URL = '/e-receipt/api';  // or full URL if needed
```

### Step 8: Test
```
1. Visit: https://your-domain.com/e-receipt/
2. Test login: admin / admin123
3. Test registration
4. Test file upload
5. Check database entries
```

---

## 🐛 Debugging 500 Errors

### Enable PHP Error Display (temporarily)
```php
// Add to top of api/config/database.php
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
```

### Check Apache Error Log
```bash
# cPanel
tail -f ~/logs/error_log

# VPS/Dedicated
tail -f /var/log/apache2/error.log
# or
tail -f /var/log/httpd/error_log
```

### Check PHP Error Log
```bash
# Look for PHP errors
tail -f /var/log/php_errors.log
```

### Test Individual API Endpoints
```bash
# Test database connection
curl https://e-receipt.lerumaenterprises.co.tz/e-receipt/api/banks/list.php

# Should return JSON with banks list
```

---

## ✅ Checklist for Production

- [ ] Database created and imported
- [ ] Database credentials updated in api/config/database.php
- [ ] File permissions set correctly (755 for dirs, 644 for files)
- [ ] api/uploads directory writable (755)
- [ ] .htaccess removed or simplified
- [ ] PHP version >= 7.4
- [ ] Required PHP extensions enabled
- [ ] Session working (test login)
- [ ] CORS configured if needed
- [ ] SSL certificate installed (HTTPS)
- [ ] Error logs checked

---

## 🔒 Security for Production

### 1. Remove .htaccess Files
```bash
# They can cause 500 errors and aren't needed
rm web/.htaccess
rm web/admin/.htaccess
rm .htaccess
```

### 2. Disable Error Display
```php
// In api/config/database.php (remove after debugging)
error_reporting(0);
ini_set('display_errors', 0);
```

### 3. Secure Uploads Directory
```apache
# Create api/uploads/.htaccess
<Files *>
  Order Deny,Allow
  Deny from all
</Files>

<FilesMatch "\.(jpg|jpeg|png|gif|pdf)$">
  Order Allow,Deny
  Allow from all
</FilesMatch>
```

### 4. Change Default Admin Password
```sql
-- In database
UPDATE users
SET password_hash = PASSWORD_HASH('your_new_secure_password', PASSWORD_BCRYPT)
WHERE username = 'admin';
```

### 5. Protect API Directory (Optional)
```apache
# Create api/.htaccess
# Only if you want extra protection
<Files *.php>
  Order Allow,Deny
  Allow from all
</Files>
```

---

## 🚀 Quick Fix for Your Current Issue

Based on the error at `https://e-receipt.lerumaenterprises.co.tz/e-receipt/web/dashboard.html`:

### Option 1: Remove All .htaccess Files
```bash
ssh to your server
cd public_html/e-receipt
find . -name ".htaccess" -delete
```

### Option 2: Check Session Configuration
```bash
# Verify session.php is accessible
curl https://e-receipt.lerumaenterprises.co.tz/e-receipt/api/config/session.php

# If it outputs PHP code, there's a routing issue
```

### Option 3: Check Error Logs
```bash
# In cPanel, go to:
# Metrics > Errors
# Look for the most recent 500 error
# It will tell you exactly what's wrong
```

### Option 4: Test API Directly
```bash
# Test if API is working
curl -v https://e-receipt.lerumaenterprises.co.tz/e-receipt/api/banks/list.php

# Expected: JSON response with banks
# Error: Check the error message
```

---

## 📞 Still Having Issues?

### Gather This Information:
1. **PHP Version:** (from cPanel or `php -v`)
2. **Error Log Content:** (last 20 lines of error_log)
3. **Permissions:** (`ls -la api/` output)
4. **Database Status:** (Can you connect via phpMyAdmin?)
5. **API Test Result:** (What does curl to banks/list.php return?)

### Common Quick Fixes:
```bash
# Fix 1: Reset permissions
chmod -R 755 e-receipt/api
chmod -R 755 e-receipt/web

# Fix 2: Clear any cached .htaccess
rm -f .htaccess*
rm -f */.htaccess

# Fix 3: Test database connection
mysql -u username -p database_name -e "SELECT COUNT(*) FROM users;"
```

---

## 📝 Production Configuration Template

Create a file: `api/config/production.php`

```php
<?php
// Production Configuration
define('PRODUCTION', true);
define('DEBUG_MODE', false);

// Database
define('DB_HOST', 'localhost');
define('DB_NAME', 'your_production_db');
define('DB_USER', 'your_db_user');
define('DB_PASS', 'your_db_password');

// Paths
define('BASE_URL', 'https://e-receipt.lerumaenterprises.co.tz/e-receipt');
define('API_URL', BASE_URL . '/api');
define('UPLOAD_PATH', __DIR__ . '/../uploads/');

// Security
define('SESSION_LIFETIME', 7200); // 2 hours
define('MAX_UPLOAD_SIZE', 10485760); // 10MB

// Error handling
if (!DEBUG_MODE) {
    error_reporting(0);
    ini_set('display_errors', 0);
}
```

---

## Contact & Support

If you're still experiencing issues, provide:
- Server type (Shared hosting / VPS / Dedicated)
- PHP version
- Error log content
- What URL exactly shows the 500 error

This will help diagnose the specific issue quickly.
