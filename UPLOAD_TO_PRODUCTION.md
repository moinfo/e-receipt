# Upload to Production - Path Fix & PDF Viewer Instructions

## Issues Resolved

### 1. Production URL Path Issue
Fixed the production URL path issue where accessing `https://e-receipt.lerumaenterprises.co.tz/e-receipt/web/dashboard.html` was causing errors. Now the system automatically redirects to the correct path.

### 2. PDF Preview Not Working
Fixed PDF files not displaying in the modal viewer. Now PDFs show embedded viewer with proper content-type headers.

## Files Updated (Version 3.3)

These files have been updated with automatic path detection and PDF viewer support:

1. **web/assets/js/app.js** - Added auto-redirect for wrong paths
2. **web/login.html** - Dynamic base path for all redirects
3. **index.html** - Auto-redirect and dynamic navigation
4. **web/dashboard.html** - Fixed PDF viewer with embed tag
5. **web/history.html** - Fixed PDF viewer with embed tag
6. **web/admin/all-receipts.html** - Fixed PDF viewer with embed tag
7. **uploads-htaccess.txt** - Configuration for proper PDF content-type headers

## Upload Instructions

### Option 1: Using FTP/FileZilla (Recommended)

1. **Connect to your server:**
   - Host: `ftp.lerumaenterprises.co.tz` or your FTP host
   - Username: Your cPanel username
   - Password: Your cPanel password

2. **Navigate to the e-receipt directory:**
   - On the server side, go to: `/public_html/e-receipt/`

3. **Upload these 11 files** (overwrite existing):

   **Frontend files:**
   ```
   index.html                        → /public_html/e-receipt/index.html
   web/assets/js/app.js              → /public_html/e-receipt/web/assets/js/app.js
   web/login.html                    → /public_html/e-receipt/web/login.html
   web/dashboard.html                → /public_html/e-receipt/web/dashboard.html
   web/history.html                  → /public_html/e-receipt/web/history.html
   web/admin/all-receipts.html       → /public_html/e-receipt/web/admin/all-receipts.html
   ```

   **Backend API files:**
   ```
   api/admin/statistics.php          → /public_html/e-receipt/api/admin/statistics.php
   api/admin/test-statistics.php     → /public_html/e-receipt/api/admin/test-statistics.php
   api/admin/users/pending.php       → /public_html/e-receipt/api/admin/users/pending.php
   api/admin/receipts/all.php        → /public_html/e-receipt/api/admin/receipts/all.php
   ```

4. **Create .htaccess in uploads directory:**
   - Copy the content from `uploads-htaccess.txt`
   - Create new file: `/public_html/e-receipt/api/uploads/.htaccess`
   - Paste the content and save

### Option 2: Using cPanel File Manager

1. **Login to cPanel:**
   - Go to your hosting control panel

2. **Open File Manager:**
   - Navigate to `public_html/e-receipt/`

3. **Upload files:**
   - Click "Upload" button
   - Select and upload the 6 HTML/JS files listed above
   - Choose "Overwrite" when prompted

4. **Create .htaccess for uploads:**
   - Navigate to `api/uploads/` directory
   - Click "New File" button
   - Name it `.htaccess`
   - Edit the file and paste content from `uploads-htaccess.txt`
   - Save the file

### Option 3: Using SSH/SCP (Advanced)

```bash
# From your local machine
cd /Applications/XAMPP/xamppfiles/htdocs/e-receipt

# Upload files via SCP
scp index.html username@e-receipt.lerumaenterprises.co.tz:/home/username/public_html/e-receipt/
scp web/assets/js/app.js username@e-receipt.lerumaenterprises.co.tz:/home/username/public_html/e-receipt/web/assets/js/
scp web/login.html username@e-receipt.lerumaenterprises.co.tz:/home/username/public_html/e-receipt/web/
scp web/dashboard.html username@e-receipt.lerumaenterprises.co.tz:/home/username/public_html/e-receipt/web/
scp web/history.html username@e-receipt.lerumaenterprises.co.tz:/home/username/public_html/e-receipt/web/
scp web/admin/all-receipts.html username@e-receipt.lerumaenterprises.co.tz:/home/username/public_html/e-receipt/web/admin/

# Create .htaccess in uploads directory
scp uploads-htaccess.txt username@e-receipt.lerumaenterprises.co.tz:/home/username/public_html/e-receipt/api/uploads/.htaccess
```

## How It Works

### For Local Environment (localhost)
- URL: `http://localhost/e-receipt/web/dashboard.html`
- Base Path: `/e-receipt`
- All links work with `/e-receipt/` prefix

### For Production Environment
- Correct URL: `https://e-receipt.lerumaenterprises.co.tz/web/dashboard.html`
- Wrong URL: `https://e-receipt.lerumaenterprises.co.tz/e-receipt/web/dashboard.html`
- **Auto-redirect:** If someone accesses the wrong URL, they are automatically redirected to the correct one
- Base Path: `` (empty, no prefix needed)

## Testing After Upload

1. **Clear browser cache** (Very Important!):
   - Chrome: `Ctrl+Shift+Delete` → Clear "Cached images and files"
   - Or use Incognito/Private mode

2. **Test wrong URL** (should auto-redirect):
   ```
   Visit: https://e-receipt.lerumaenterprises.co.tz/e-receipt/web/dashboard.html
   Should redirect to: https://e-receipt.lerumaenterprises.co.tz/web/dashboard.html
   ```

3. **Test index page:**
   ```
   Visit: https://e-receipt.lerumaenterprises.co.tz/e-receipt/
   Or: https://e-receipt.lerumaenterprises.co.tz/
   Both should work and redirect properly
   ```

4. **Test login:**
   - Click "Login as User" button
   - Should navigate to: `https://e-receipt.lerumaenterprises.co.tz/web/login.html`

5. **Test after login:**
   - Login with credentials
   - Should redirect to dashboard at correct path

## What Was Changed

### 1. Path Detection & Auto-Redirect

**web/assets/js/app.js (Lines 6-13)**
```javascript
// Auto-redirect from wrong production path
if (window.location.hostname !== 'localhost' &&
    window.location.hostname !== '127.0.0.1' &&
    window.location.pathname.includes('/e-receipt/web/')) {
    const correctPath = window.location.pathname.replace('/e-receipt/web/', '/web/');
    window.location.href = window.location.origin + correctPath;
}

// Auto-detect base path
const BASE_PATH = window.location.pathname.includes('/e-receipt/') ? '/e-receipt' : '';
const API_BASE_URL = BASE_PATH + '/api';
```

**web/login.html (Lines 188-229)**
```javascript
// Dynamic base path in redirects
const basePath = window.location.pathname.includes('/e-receipt/') ? '/e-receipt' : '';
window.location.href = basePath + '/web/dashboard.html';
```

**index.html (Lines 324-346)**
```javascript
// Auto-redirect from /e-receipt/ to root on production
if (window.location.hostname !== 'localhost' &&
    window.location.pathname.includes('/e-receipt/')) {
    const correctPath = window.location.pathname.replace('/e-receipt/', '/');
    window.location.href = window.location.origin + correctPath;
}

// Dynamic navigation function
const BASE_PATH = window.location.pathname.includes('/e-receipt/') ? '/e-receipt' : '';
function navigateTo(path) {
    window.location.href = BASE_PATH + '/' + path;
}
```

### 2. PDF Viewer Fix

**All receipt viewer pages (dashboard.html, history.html, all-receipts.html)**
```javascript
// Detect if file is PDF
const receiptUrl = BASE_PATH + '/api/' + imagePath;
const isPDF = imagePath.toLowerCase().endsWith('.pdf');

if (isPDF) {
    // For PDFs, show embedded viewer
    mediaHTML = `<embed src="${receiptUrl}" type="application/pdf" style="width: 100%; height: 500px; border-radius: 8px;">`;
} else {
    // For images, show image
    mediaHTML = `<img src="${receiptUrl}" alt="Receipt" style="width: 100%; border-radius: 8px;">`;
}
```

### 3. Uploads Directory Configuration

**api/uploads/.htaccess**
- Set correct MIME types for PDF files
- Enable CORS headers for cross-origin access
- Security: Prevent PHP execution in uploads directory
- Cache control for better performance

## Troubleshooting

### Issue: Still seeing old behavior
**Solution:** Clear browser cache completely or use Incognito mode

### Issue: 404 Not Found
**Solution:** Make sure files are in the correct directory:
- Production: `/public_html/e-receipt/web/`
- NOT: `/public_html/web/`

### Issue: JavaScript errors
**Solution:** Check browser console (F12) for specific errors

### Issue: Files won't upload
**Solution:**
- Check file permissions on server (should be 644 for files)
- Make sure you have write permissions to the directory

### Issue: Admin statistics showing 500 error
**Symptoms:**
- Admin dashboard shows error loading statistics
- Console shows: "SyntaxError: Unexpected token '<', "<!DOCTYPE "... is not valid JSON"
- API returns 500 Internal Server Error

**Debugging Steps:**
1. **Access the test endpoint:**
   ```
   Visit: https://e-receipt.lerumaenterprises.co.tz/api/admin/test-statistics.php
   ```
   This will show step-by-step what's failing

2. **Check if logged in:**
   - Make sure you're logged in as admin first
   - Visit: `/web/admin/login.html` and login

3. **Check file paths:**
   - Ensure all files are in correct directories
   - Verify `api/config/session.php` exists
   - Verify `api/config/database.php` exists
   - Verify `api/models/User.php` exists
   - Verify `api/models/Receipt.php` exists

4. **Check database connection:**
   - Verify database credentials in `api/config/database.php`
   - Test connection via phpMyAdmin

5. **Check .htaccess:**
   - If you have `.htaccess` in `/api/` or `/api/admin/`, try removing it temporarily
   - Server might be blocking the request

6. **Check PHP version:**
   - Requires PHP 7.4 or higher
   - Check: `php -v` or in cPanel

**Solutions:**
```bash
# Fix permissions
chmod 644 api/admin/statistics.php
chmod 644 api/admin/test-statistics.php

# Remove blocking .htaccess
rm api/.htaccess
rm api/admin/.htaccess
```

## Verification Checklist

After uploading, verify these URLs work:

- [ ] `https://e-receipt.lerumaenterprises.co.tz/` - Shows index page
- [ ] `https://e-receipt.lerumaenterprises.co.tz/e-receipt/` - Shows index page
- [ ] `https://e-receipt.lerumaenterprises.co.tz/web/login.html` - Shows login page
- [ ] `https://e-receipt.lerumaenterprises.co.tz/e-receipt/web/login.html` - Redirects to correct path
- [ ] Login works and redirects to correct dashboard URL
- [ ] All navigation buttons work correctly
- [ ] Click "View" on a receipt - Modal opens
- [ ] PDF receipts show embedded viewer (not blank)
- [ ] Image receipts display properly
- [ ] "Open in New Tab" opens PDF in new tab successfully
- [ ] "Download" button downloads the file

## Support

If you encounter any issues:
1. Check browser console for JavaScript errors (F12 → Console)
2. Verify files were uploaded to correct locations
3. Clear browser cache completely
4. Try in Incognito/Private mode
5. Check Apache error logs in cPanel

---

## Summary

**Version:** 3.5
**Date:** 2025-11-06
**Status:** Ready for Production Upload

### Files to Upload (11 files):

**Web Frontend (6 files):**
1. `index.html`
2. `web/assets/js/app.js`
3. `web/login.html`
4. `web/dashboard.html`
5. `web/history.html`
6. `web/admin/all-receipts.html`

**API Backend (5 files):**
7. `api/admin/statistics.php` (improved error handling)
8. `api/admin/test-statistics.php` (debugging tool)
9. `api/admin/users/pending.php` (improved error handling)
10. `api/admin/receipts/all.php` (improved error handling)

### Additional Configuration:
11. Create `api/uploads/.htaccess` (copy from `uploads-htaccess.txt`)

### Features Fixed:
✅ Production URL path auto-redirect
✅ PDF viewer with embedded display
✅ Dynamic path detection (works on both local and production)
✅ Proper MIME types for PDF files
✅ Security: Prevent PHP execution in uploads
✅ Admin statistics API with better error handling
✅ Admin pending users API with better error handling
✅ Admin receipts API with better error handling
✅ Test endpoint for debugging 500 errors
✅ All APIs now return JSON errors (not HTML)
