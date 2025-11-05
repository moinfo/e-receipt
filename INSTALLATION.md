# E-Receipt System - Installation Guide

## Quick Start Guide

Follow these steps to get your e-receipt system up and running.

### Prerequisites

- XAMPP (or similar LAMP/WAMP stack)
- PHP 7.4 or higher
- MySQL 5.7 or higher
- Modern web browser

### Step 1: Database Setup

1. **Start MySQL Server**
   - Open XAMPP Control Panel
   - Click "Start" for Apache and MySQL

2. **Create Database**
   - Open phpMyAdmin: `http://localhost/phpmyadmin`
   - Click "New" to create a new database
   - Database name: `ereceipt_db`
   - Collation: `utf8mb4_unicode_ci`
   - Click "Create"

3. **Import Database Schema**
   - Select `ereceipt_db` database
   - Click "Import" tab
   - Click "Choose File"
   - Navigate to: `/Applications/XAMPP/xamppfiles/htdocs/e-receipt/database/schema.sql`
   - Click "Go"
   - Wait for success message

4. **Import Sample Data (Optional)**
   - Still in Import tab
   - Choose file: `/Applications/XAMPP/xamppfiles/htdocs/e-receipt/database/seed.sql`
   - Click "Go"
   - This will create an admin account and sample data

### Step 2: Configure Database Connection

1. **Edit Database Configuration**
   - Open file: `/Applications/XAMPP/xamppfiles/htdocs/e-receipt/api/config/database.php`
   - Update the following if needed:
   ```php
   define('DB_HOST', 'localhost');
   define('DB_NAME', 'ereceipt_db');
   define('DB_USER', 'root');
   define('DB_PASS', '');  // Add your MySQL password if you have one
   ```

### Step 3: Set Folder Permissions

1. **Create Uploads Directory**
   ```bash
   mkdir -p /Applications/XAMPP/xamppfiles/htdocs/e-receipt/api/uploads/receipts
   ```

2. **Set Permissions** (Mac/Linux)
   ```bash
   chmod -R 777 /Applications/XAMPP/xamppfiles/htdocs/e-receipt/api/uploads/
   ```

   **Windows Users:** Right-click the `uploads` folder → Properties → Security → Edit → Add "Everyone" with Full Control

### Step 4: Access the Application

1. **Open Web Browser**
   - Navigate to: `http://localhost/e-receipt/web/`

2. **Login with Admin Account** (if you imported seed data)
   - Username: `admin`
   - Password: `admin123`
   - **IMPORTANT:** Change this password immediately!

3. **Or Register a New Account**
   - Click "Register"
   - Fill in the form
   - Wait for admin approval

### Step 5: Test the System

#### For Regular Users:
1. Register a new account
2. Wait for admin approval (or approve yourself if you're admin)
3. Login after approval
4. Upload a receipt
5. View your receipt history

#### For Admin:
1. Login with admin credentials
2. Approve/reject pending users
3. View all receipts
4. View system statistics

## Default Admin Credentials

```
Username: admin
Password: admin123
```

**⚠️ SECURITY WARNING:** Change the default admin password immediately after first login!

## Troubleshooting

### Issue: "Database connection failed"
**Solution:**
- Verify MySQL is running in XAMPP
- Check database credentials in `api/config/database.php`
- Ensure database `ereceipt_db` exists

### Issue: "Cannot upload receipts"
**Solution:**
- Check uploads folder exists: `api/uploads/receipts/`
- Verify folder permissions (777)
- Check PHP settings in `php.ini`:
  ```
  upload_max_filesize = 10M
  post_max_size = 10M
  ```

### Issue: "Login not working"
**Solution:**
- Clear browser cookies and cache
- Check if user status is 'approved' in database
- Verify PHP session is enabled

### Issue: "Page not found (404)"
**Solution:**
- Verify XAMPP Apache is running
- Check the URL path is correct
- Ensure files are in: `/Applications/XAMPP/xamppfiles/htdocs/e-receipt/`

## File Structure Verification

Your installation should have these directories:

```
e-receipt/
├── README.md
├── INSTALLATION.md
├── database/
│   ├── schema.sql
│   └── seed.sql
├── api/
│   ├── config/
│   ├── models/
│   ├── auth/
│   ├── receipts/
│   ├── banks/
│   ├── admin/
│   └── uploads/
└── web/
    ├── index.html
    ├── login.html
    ├── register.html
    └── assets/
        └── css/
            └── style.css
```

## Next Steps

1. **Change Admin Password**
   - Login as admin
   - Go to settings/profile
   - Change password

2. **Add Banks**
   - Login as admin
   - Go to bank management
   - Add your required banks

3. **Invite Users**
   - Share registration link with users
   - Approve their accounts

4. **Test Receipt Upload**
   - Upload a test receipt
   - Verify it appears in history
   - Check admin can see it

## Mobile App (Flutter)

The mobile app setup will be covered in a separate guide. For now, the web application is fully functional.

## Security Recommendations

1. ✅ Change default admin password
2. ✅ Use strong passwords for all accounts
3. ✅ Set proper file permissions
4. ✅ Keep PHP and MySQL updated
5. ✅ Enable HTTPS in production
6. ✅ Regular database backups
7. ✅ Monitor upload folder size

## Support

For issues or questions:
- Check the README.md file
- Review the troubleshooting section above
- Check browser console for JavaScript errors
- Check Apache error logs in XAMPP

## Backup

**Important Database Backup Command:**
```bash
mysqldump -u root -p ereceipt_db > backup_$(date +%Y%m%d).sql
```

Run this regularly to backup your data!

---

**Congratulations! Your E-Receipt System is now installed and ready to use!** 🎉
