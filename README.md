# E-Receipt Management System

![Version](https://img.shields.io/badge/version-3.5-blue)
![PHP](https://img.shields.io/badge/PHP-7.4+-purple)
![MySQL](https://img.shields.io/badge/MySQL-5.7+-orange)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A comprehensive digital receipt management system with admin approval workflow, built with PHP, MySQL, and Flutter.

## 🌟 Features

### User Features
- ✅ Self-registration with admin approval
- ✅ Receipt upload (images & PDFs up to 10MB)
- ✅ Receipt history with date range filters
- ✅ Bank selection for receipts
- ✅ Receipt status tracking (Pending/Approved/Rejected)
- ✅ Password recovery via security questions
- ✅ Mobile responsive design

### Admin Features
- ✅ Dashboard with statistics
- ✅ User management (approve/reject/delete)
- ✅ Receipt approval workflow
- ✅ Bank CRUD operations
- ✅ View all receipts with filters
- ✅ Pending users review

### Technical Features
- ✅ Session-based authentication
- ✅ Bcrypt password hashing
- ✅ SQL injection prevention (prepared statements)
- ✅ XSS protection
- ✅ PDF viewer with embedded display
- ✅ Dynamic path detection (works on localhost & production)
- ✅ RESTful API architecture

## 🚀 Quick Start

```bash
# Clone repository
git clone git@github.com:moinfo/e-receipt.git
cd e-receipt

# Setup database
mysql -u root -p ereceipt_db < database/schema.sql

# Configure
cp api/config/database.example.php api/config/database.php
# Edit database.php with your credentials

# Access
http://localhost/e-receipt/
```

**Default Credentials:**
- Admin: `admin` / `admin123`
- User: `johndoe` / `password123`

## 📖 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Deployment Guide](UPLOAD_TO_PRODUCTION.md)
- [Git Setup](GIT_SETUP_GUIDE.md)
- [API Documentation](docs/API.md)
- [Security Guide](ADMIN_500_ERROR_FIX.md)

## 🔒 Security

- ✅ Prepared statements (SQL injection prevention)
- ✅ Bcrypt password hashing
- ✅ Session HttpOnly cookies
- ✅ XSS prevention
- ✅ File upload validation

## 📱 Mobile App

Flutter mobile app (code complete, requires testing)

```bash
cd mobile_app
flutter pub get
flutter run
```

## 🤝 Contributing

Pull requests welcome! See [CONTRIBUTING.md](CONTRIBUTING.md)

## 📝 License

MIT License - see [LICENSE](LICENSE)

---

Made with ❤️ for efficient receipt management
