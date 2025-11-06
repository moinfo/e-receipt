# E-Receipt API Documentation

**Base URL (Production):** `https://e-receipt.lerumaenterprises.co.tz/api`
**Base URL (Local):** `http://YOUR_LOCAL_IP/e-receipt/api`

**Last Updated:** November 6, 2025
**API Version:** 3.5
**SSL Certificate:** Valid (Let's Encrypt)
**Certificate Expiry:** February 3, 2026

---

## Authentication

All API endpoints (except banks/list.php) require authentication via session-based cookies or tokens.

### Response Format

All API responses follow this standard format:

```json
{
  "success": true|false,
  "message": "Human readable message",
  "data": { ... },
  "count": 0  // Optional, for list endpoints
}
```

---

## Endpoints

### 1. Authentication Endpoints

#### 1.1 Login
**Endpoint:** `POST /auth/login.php`

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user_id": 1,
    "username": "john_doe",
    "full_name": "John Doe",
    "phone": "255712345678",
    "is_admin": 0
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

---

#### 1.2 Register
**Endpoint:** `POST /auth/register.php`

**Request Body:**
```json
{
  "username": "string",
  "password": "string",
  "full_name": "string",
  "phone": "string"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user_id": 1,
    "username": "john_doe"
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Username already exists"
}
```

---

#### 1.3 Logout
**Endpoint:** `POST /auth/logout.php`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

---

### 2. Bank Endpoints

#### 2.1 List Banks
**Endpoint:** `GET /banks/list.php`

**Authentication:** Not required

**Success Response (200):**
```json
{
  "success": true,
  "message": "Banks retrieved successfully",
  "data": [
    {
      "id": 1,
      "bank_name": "CRDB",
      "bank_code": "CRDB",
      "status": "active",
      "created_at": "2025-11-05 21:37:08"
    },
    {
      "id": 2,
      "bank_name": "NMB",
      "bank_code": "NMB",
      "status": "active",
      "created_at": "2025-11-05 21:37:08"
    },
    {
      "id": 3,
      "bank_name": "NBC",
      "bank_code": "NBC",
      "status": "active",
      "created_at": "2025-11-05 21:37:08"
    }
  ],
  "count": 3
}
```

**Test Result:** ✅ Verified Working (Nov 6, 2025)
- Response Time: ~1 second
- SSL: Valid
- CORS: Enabled

---

### 3. Receipt Endpoints

#### 3.1 Upload Receipt
**Endpoint:** `POST /receipts/upload.php`

**Content-Type:** `multipart/form-data`

**Request Body:**
```
user_id: integer
bank_id: integer
amount: decimal
receipt_image: file (image/jpeg, image/png)
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Receipt uploaded successfully",
  "data": {
    "receipt_id": 1,
    "status": "pending"
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Invalid file format"
}
```

---

#### 3.2 User Receipt History
**Endpoint:** `GET /receipts/user-history.php`

**Query Parameters:**
- `user_id` (required): integer

**Example:** `/receipts/user-history.php?user_id=1`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Receipts retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "bank_id": 1,
      "bank_name": "CRDB",
      "amount": 150000.00,
      "receipt_image_path": "uploads/receipts/receipt_123.jpg",
      "status": "pending",
      "uploaded_at": "2025-11-06 10:30:00",
      "approved_at": null
    }
  ],
  "count": 1
}
```

**Status Values:**
- `pending` - Awaiting admin approval
- `approved` - Approved by admin
- `rejected` - Rejected by admin

---

#### 3.3 User Statistics
**Endpoint:** `GET /receipts/user-statistics.php`

**Query Parameters:**
- `user_id` (required): integer

**Example:** `/receipts/user-statistics.php?user_id=1`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Statistics retrieved successfully",
  "data": {
    "total_receipts": 10,
    "pending_receipts": 3,
    "approved_receipts": 6,
    "rejected_receipts": 1,
    "total_amount": 1500000.00
  }
}
```

---

### 4. Admin Endpoints

**Note:** All admin endpoints require `is_admin = 1` in user session.

#### 4.1 Admin Statistics
**Endpoint:** `GET /admin/statistics.php`

**Authentication:** Admin only

**Success Response (200):**
```json
{
  "success": true,
  "message": "Statistics retrieved successfully",
  "data": {
    "users": {
      "total_users": 150,
      "pending_users": 10,
      "approved_users": 135,
      "rejected_users": 5
    },
    "receipts": {
      "total_receipts": 500,
      "total_users_uploaded": 120,
      "banks_used": 3,
      "total_amount": 75000000.00
    }
  }
}
```

---

#### 4.2 Admin Receipts List
**Endpoint:** `GET /admin/receipts.php`

**Authentication:** Admin only

**Query Parameters:**
- `status` (optional): pending|approved|rejected
- `page` (optional): integer (default: 1)
- `limit` (optional): integer (default: 20)

**Example:** `/admin/receipts.php?status=pending&page=1&limit=10`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Receipts retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 5,
      "username": "john_doe",
      "full_name": "John Doe",
      "bank_id": 1,
      "bank_name": "CRDB",
      "amount": 150000.00,
      "receipt_image_path": "uploads/receipts/receipt_123.jpg",
      "status": "pending",
      "uploaded_at": "2025-11-06 10:30:00",
      "approved_at": null
    }
  ],
  "count": 1,
  "total_pages": 5,
  "current_page": 1
}
```

---

#### 4.3 Admin Users List
**Endpoint:** `GET /admin/users.php`

**Authentication:** Admin only

**Query Parameters:**
- `status` (optional): pending|approved|rejected
- `page` (optional): integer (default: 1)
- `limit` (optional): integer (default: 20)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Users retrieved successfully",
  "data": [
    {
      "id": 1,
      "username": "john_doe",
      "full_name": "John Doe",
      "phone": "255712345678",
      "status": "approved",
      "is_admin": 0,
      "created_at": "2025-11-05 10:00:00",
      "total_receipts": 5,
      "total_amount": 500000.00
    }
  ],
  "count": 1,
  "total_pages": 8,
  "current_page": 1
}
```

---

#### 4.4 Approve Receipt
**Endpoint:** `POST /admin/approve-receipt.php`

**Authentication:** Admin only

**Request Body:**
```json
{
  "receipt_id": 1,
  "action": "approve|reject"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Receipt approved successfully",
  "data": {
    "receipt_id": 1,
    "status": "approved",
    "approved_at": "2025-11-06 15:30:00"
  }
}
```

---

## Error Codes

| HTTP Code | Description |
|-----------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Authentication required |
| 403 | Forbidden - Insufficient privileges |
| 404 | Not Found - Resource doesn't exist |
| 500 | Internal Server Error |

---

## Common Error Responses

### Invalid Authentication
```json
{
  "success": false,
  "message": "Authentication required"
}
```

### Insufficient Privileges
```json
{
  "success": false,
  "message": "Admin access required"
}
```

### Validation Error
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "field_name": "Error message"
  }
}
```

---

## CORS Configuration

The API supports Cross-Origin Resource Sharing (CORS):
- **Access-Control-Allow-Origin:** * (all origins)
- **Access-Control-Allow-Methods:** GET, POST, PUT, DELETE
- **Access-Control-Allow-Headers:** Content-Type, Authorization

---

## File Upload Guidelines

### Receipt Images
- **Accepted Formats:** JPEG, PNG
- **Maximum Size:** 5 MB
- **Recommended Resolution:** 1080x1920 (portrait)
- **Storage Location:** `uploads/receipts/`
- **Naming Convention:** `receipt_{timestamp}_{user_id}.{ext}`

---

## Rate Limiting

**Current Status:** Not implemented

**Recommended Limits:**
- Authentication endpoints: 5 requests per minute
- Upload endpoints: 10 requests per hour
- Read endpoints: 100 requests per minute

---

## Testing the API

### Using cURL

**Test Bank List:**
```bash
curl -X GET "https://e-receipt.lerumaenterprises.co.tz/api/banks/list.php" \
  -H "Content-Type: application/json"
```

**Test Login:**
```bash
curl -X POST "https://e-receipt.lerumaenterprises.co.tz/api/auth/login.php" \
  -H "Content-Type: application/json" \
  -d '{"username":"test_user","password":"test_pass"}'
```

**Test Receipt Upload:**
```bash
curl -X POST "https://e-receipt.lerumaenterprises.co.tz/api/receipts/upload.php" \
  -F "user_id=1" \
  -F "bank_id=1" \
  -F "amount=150000" \
  -F "receipt_image=@/path/to/receipt.jpg"
```

---

## Flutter Integration

### Example API Call

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> fetchBanks() async {
  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/banks/list.php'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load banks');
  }
}
```

---

## Environment Configuration

### Production
```dart
static const String prodUrl = 'https://e-receipt.lerumaenterprises.co.tz/api';
static const bool useProduction = true;
```

### Local Development
```dart
static const String localUrl = 'http://192.168.0.100/e-receipt/api';
static const bool useProduction = false;
```

### Android Emulator
```dart
static const String localUrl = 'http://10.0.2.2/e-receipt/api';
```

### iOS Simulator
```dart
static const String localUrl = 'http://localhost/e-receipt/api';
```

---

## SSL Certificate Information

**Domain:** e-receipt.lerumaenterprises.co.tz
**Issuer:** Let's Encrypt (R12)
**Valid From:** November 5, 2025
**Valid Until:** February 3, 2026
**Protocol:** TLS 1.3
**Cipher:** AEAD-AES256-GCM-SHA384

**Certificate Chain:**
- Root CA: Let's Encrypt
- Intermediate: R12
- Leaf: www.e-receipt.lerumaenterprises.co.tz

---

## Server Information

**IP Address:** 108.178.26.90
**Server Software:** Apache
**PHP Version:** (To be verified)
**Database:** MySQL/MariaDB

---

## Best Practices

### 1. Error Handling
Always handle both success and error responses:
```dart
try {
  final response = await apiCall();
  if (response['success']) {
    // Handle success
  } else {
    // Handle API-level error
    showError(response['message']);
  }
} catch (e) {
  // Handle network/parsing errors
  showError('Network error occurred');
}
```

### 2. Loading States
Show loading indicators during API calls:
```dart
setState(() => isLoading = true);
try {
  final data = await fetchData();
  // Process data
} finally {
  setState(() => isLoading = false);
}
```

### 3. Authentication Persistence
Store authentication tokens securely:
```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}
```

### 4. Image Optimization
Compress images before upload:
```dart
import 'package:image/image.dart' as img;

Future<File> compressImage(File file) async {
  final image = img.decodeImage(file.readAsBytesSync());
  final compressed = img.encodeJpg(image!, quality: 85);
  return File(file.path)..writeAsBytesSync(compressed);
}
```

---

## Changelog

### Version 3.5 (November 6, 2025)
- ✅ Verified bank API endpoint
- ✅ Added production URL configuration
- ✅ Documented all endpoints
- ✅ Added SSL certificate information
- ✅ Added testing guidelines

---

## Support

For API issues or questions:
- **Email:** support@lerumaenterprises.co.tz
- **Documentation:** This file
- **Build Configuration:** BUILD_CONFIGURATION.md

---

**Last Tested:** November 6, 2025
**Status:** ✅ Production API is operational
