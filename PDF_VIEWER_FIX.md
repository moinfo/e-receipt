# PDF Viewer Fix - Technical Summary

## Issue Description
When viewing PDF receipts in the modal, the viewer showed a blank page instead of displaying the PDF content.

Example URL that wasn't working:
```
https://e-receipt.lerumaenterprises.co.tz/api/uploads/receipts/receipt_6_1762371748_690ba8a4c0d76.pdf
```

## Root Causes

### 1. Incorrect URL Path Construction
**Problem:**
```javascript
// OLD CODE (incorrect)
<img src="../api/${imagePath}" alt="Receipt">
```

The `imagePath` variable already contains the path like `uploads/receipts/receipt_6_1762371748_690ba8a4c0d76.pdf`, so combining it with `../api/` resulted in incorrect URLs.

**Solution:**
```javascript
// NEW CODE (correct)
const receiptUrl = BASE_PATH + '/api/' + imagePath;
```

### 2. No PDF Detection
**Problem:**
The code was using `<img>` tag for all files, including PDFs. Image tags cannot display PDF files.

**Solution:**
```javascript
const isPDF = imagePath.toLowerCase().endsWith('.pdf');

if (isPDF) {
    // Use <embed> tag for PDFs
    mediaHTML = `<embed src="${receiptUrl}" type="application/pdf" style="width: 100%; height: 500px;">`;
} else {
    // Use <img> tag for images
    mediaHTML = `<img src="${receiptUrl}" alt="Receipt">`;
}
```

### 3. Missing MIME Type Configuration
**Problem:**
Server might not be sending correct `Content-Type: application/pdf` header for PDF files.

**Solution:**
Created `.htaccess` file in `api/uploads/` directory:
```apache
<IfModule mod_mime.c>
    AddType application/pdf .pdf
    AddType image/jpeg .jpg .jpeg
    AddType image/png .png
    AddType image/gif .gif
</IfModule>
```

## Files Modified

### 1. web/dashboard.html
- **Location:** Lines 235-273
- **Function:** `viewReceipt(id, imagePath)`
- **Changes:**
  - Added `receiptUrl` construction using `BASE_PATH`
  - Added `isPDF` detection
  - Conditional rendering: `<embed>` for PDF, `<img>` for images

### 2. web/history.html
- **Location:** Lines 253-305
- **Function:** `viewReceipt(id, imagePath, receiptData)`
- **Changes:**
  - Added `receiptUrl` construction using `BASE_PATH`
  - Added `isPDF` detection
  - Conditional rendering: `<embed>` for PDF, `<img>` for images
  - Updated "Open in New Tab" and "Download" links to use `receiptUrl`

### 3. web/admin/all-receipts.html
- **Location:** Lines 238-299
- **Function:** `viewReceipt(receiptId)`
- **Changes:**
  - Added `receiptUrl` construction using `BASE_PATH`
  - Added `isPDF` detection
  - Conditional rendering: `<embed>` for PDF, `<img>` for images
  - Updated "Open in New Tab" and "Download" links to use `receiptUrl`

### 4. uploads-htaccess.txt (NEW FILE)
- **Purpose:** Configuration template for `api/uploads/.htaccess`
- **Contents:**
  - MIME type definitions
  - Security rules (prevent PHP execution)
  - CORS headers
  - Cache control

## How the Fix Works

### Before (Broken):
```
User clicks "View" on PDF receipt
  ↓
Modal opens with: <img src="../api/uploads/receipts/file.pdf">
  ↓
Browser tries to load PDF as image
  ↓
❌ Blank page shown (browsers can't display PDF in <img> tag)
```

### After (Fixed):
```
User clicks "View" on PDF receipt
  ↓
JavaScript detects file extension is .pdf
  ↓
Modal opens with: <embed src="BASE_PATH/api/uploads/receipts/file.pdf" type="application/pdf">
  ↓
Server sends file with Content-Type: application/pdf
  ↓
✅ Browser's PDF viewer displays the file embedded in the modal
```

## Testing

### Local Environment (localhost):
1. Upload a PDF receipt
2. Click "View" on the receipt
3. Modal should show embedded PDF viewer
4. Scroll to view full PDF content
5. Click "Open in New Tab" - PDF opens in new browser tab
6. Click "Download" - PDF downloads to computer

### Production Environment:
Same testing steps as above, plus:
1. Test URL: `https://e-receipt.lerumaenterprises.co.tz/api/uploads/receipts/receipt_6_1762371748_690ba8a4c0d76.pdf`
2. Should display PDF in browser (not download)
3. Check browser DevTools Network tab:
   - Response Header should show: `Content-Type: application/pdf`

## Browser Compatibility

The `<embed>` tag is supported by all modern browsers:
- ✅ Chrome 1+
- ✅ Firefox 1+
- ✅ Safari 1+
- ✅ Edge 12+
- ✅ Opera 8+

**Fallback:** If browser doesn't support embedded PDF viewing, the "Open in New Tab" button will still work.

## Security Considerations

### Uploads Directory Protection
The `.htaccess` file includes security measures:

1. **Prevent PHP Execution:**
```apache
<FilesMatch "\.php$">
    Order Deny,Allow
    Deny from all
</FilesMatch>
```
This prevents attackers from uploading malicious PHP files disguised as receipts.

2. **Allow Only Specific File Types:**
```apache
<FilesMatch "\.(jpg|jpeg|png|gif|pdf)$">
    Order Allow,Deny
    Allow from all
</FilesMatch>
```
Only image and PDF files can be accessed directly.

3. **Disable Directory Listing:**
```apache
Options -Indexes
```
Prevents users from browsing the uploads directory.

## Performance Optimization

### Cache Headers
The `.htaccess` includes cache control:
```apache
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
    ExpiresByType application/pdf "access plus 1 week"
</IfModule>
```

Benefits:
- Images cached for 1 month (receipts rarely change)
- PDFs cached for 1 week
- Reduces server load
- Faster page loads for returning users

## Troubleshooting

### Issue: PDF still shows blank
**Check:**
1. Browser console for errors (F12 → Console)
2. Network tab - verify PDF file is being downloaded
3. Response headers - should have `Content-Type: application/pdf`

**Solutions:**
- Clear browser cache
- Check `.htaccess` file is properly uploaded
- Verify file permissions (644 for files, 755 for directories)

### Issue: "Download" instead of "View"
**Cause:** Server sending `Content-Disposition: attachment` header

**Solution:** Check PHP code or `.htaccess` for forced download headers

### Issue: CORS error
**Cause:** Cross-origin requests being blocked

**Solution:** Ensure `.htaccess` has CORS headers:
```apache
Header set Access-Control-Allow-Origin "*"
Header set Access-Control-Allow-Methods "GET, OPTIONS"
```

## Additional Notes

- The `<embed>` tag has a fixed height of 500px for consistent display
- The viewer is responsive and adapts to modal width
- Images continue to use `<img>` tag for better compatibility
- The fix works on both local and production environments due to `BASE_PATH` detection

---

**Version:** 3.3
**Date:** 2025-11-06
**Status:** Tested and Ready for Production
