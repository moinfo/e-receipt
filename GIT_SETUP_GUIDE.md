# Git Setup Guide - E-Receipt System

## Quick Start

### Initial Setup

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/e-receipt

# Initialize Git repository
git init

# Add all files (respects .gitignore)
git add .

# Create first commit
git commit -m "Initial commit: E-Receipt Management System v3.5"
```

## Important: Before First Commit

### 1. Protect Sensitive Files

**Critical:** Make sure these files are NOT committed:

```bash
# Check if database.php is ignored
git status | grep database.php

# Should show nothing (ignored)
# If it shows as tracked, run:
git rm --cached api/config/database.php
```

### 2. Create Example Configuration

```bash
# Copy database config as example (already done)
# Users will copy database.example.php to database.php
```

### 3. Verify .gitignore is Working

```bash
# Check what will be committed
git status

# Should NOT see:
# - api/uploads/receipts/*.pdf
# - api/uploads/receipts/*.jpg
# - api/config/database.php
# - *.log files
# - .DS_Store files
```

## Connecting to GitHub/GitLab

### Option 1: GitHub

```bash
# Create new repository on GitHub (do this first)
# Then link it:
git remote add origin https://github.com/yourusername/e-receipt.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Option 2: GitLab

```bash
# Create new repository on GitLab (do this first)
# Then link it:
git remote add origin https://gitlab.com/yourusername/e-receipt.git

# Push to GitLab
git branch -M main
git push -u origin main
```

### Option 3: Private Server

```bash
# Setup SSH key first (if not done)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Add remote
git remote add origin user@your-server.com:/path/to/repo.git

# Push
git push -u origin main
```

## Directory Structure (What Gets Committed)

```
✅ Committed to Git:
e-receipt/
├── api/
│   ├── admin/              ✅ All PHP files
│   ├── auth/               ✅ All PHP files
│   ├── config/
│   │   ├── database.example.php  ✅ Example only
│   │   └── session.php           ✅ Safe to commit
│   ├── models/             ✅ All PHP files
│   ├── receipts/           ✅ All PHP files
│   └── banks/              ✅ All PHP files
├── web/
│   ├── admin/              ✅ All HTML files
│   ├── assets/             ✅ All CSS/JS/images
│   ├── *.html              ✅ All HTML files
├── database/
│   ├── schema.sql          ✅ Database structure
│   ├── seed.sql            ✅ Initial data
│   └── migrations/         ✅ All migrations
├── mobile_app/
│   ├── lib/                ✅ Dart source files
│   ├── android/            ⚠️  Partial (see .gitignore)
│   ├── ios/                ⚠️  Partial (see .gitignore)
│   └── pubspec.yaml        ✅ Flutter config
├── .gitignore              ✅
├── README.md               ✅
└── *.md                    ✅ Documentation

❌ NOT Committed (Ignored):
├── api/
│   ├── config/database.php       ❌ Sensitive credentials
│   ├── uploads/receipts/*        ❌ User files
│   └── logs/                     ❌ Log files
├── .DS_Store                     ❌ macOS junk
├── *.log                         ❌ Error logs
├── node_modules/                 ❌ Dependencies
├── vendor/                       ❌ PHP dependencies
└── mobile_app/build/             ❌ Build output
```

## Common Git Commands

### Daily Development

```bash
# Check status
git status

# Add specific files
git add web/dashboard.html
git add api/receipts/upload.php

# Add all changes
git add .

# Commit with message
git commit -m "Fix: PDF viewer displaying blank pages"

# Push to remote
git push origin main
```

### Branching Strategy

```bash
# Create feature branch
git checkout -b feature/email-notifications

# Work on feature...
git add .
git commit -m "Add: Email notification system"

# Switch back to main
git checkout main

# Merge feature
git merge feature/email-notifications

# Delete feature branch
git branch -d feature/email-notifications
```

### Recommended Branch Names

```bash
# Features
feature/export-csv
feature/bulk-operations
feature/activity-logging

# Bug fixes
fix/pdf-viewer-blank
fix/admin-500-error
fix/session-timeout

# Security
security/csrf-protection
security/rate-limiting

# Performance
perf/database-indexes
perf/query-optimization

# Documentation
docs/api-documentation
docs/deployment-guide
```

## .gitignore Breakdown

### Why Each Section Exists

**Sensitive Configuration:**
- Prevents committing database passwords
- Protects API keys and secrets

**User Uploaded Files:**
- Keeps user data private
- Reduces repository size
- Uploaded receipts contain sensitive info

**Log Files:**
- Change frequently
- Can contain sensitive debug info
- Large and unnecessary for version control

**IDE Files:**
- Personal preferences
- Should not be shared
- Different developers use different editors

**OS Files:**
- .DS_Store (macOS)
- Thumbs.db (Windows)
- System-specific, not code

**Dependencies:**
- Can be reinstalled via composer/npm
- Large and bloat repository
- Version-locked via composer.lock/package-lock.json

## Setup for New Developers

When someone clones the repository:

```bash
# Clone repository
git clone https://github.com/yourusername/e-receipt.git
cd e-receipt

# Copy example config
cp api/config/database.example.php api/config/database.php

# Edit with your credentials
nano api/config/database.php

# Create uploads directory (if needed)
mkdir -p api/uploads/receipts
chmod 755 api/uploads
chmod 755 api/uploads/receipts

# Import database
mysql -u root -p ereceipt_db < database/schema.sql
mysql -u root -p ereceipt_db < database/seed.sql

# Start development
# Open http://localhost/e-receipt/
```

## GitHub Best Practices

### Create README.md Badges

```markdown
# E-Receipt Management System

![Version](https://img.shields.io/badge/version-3.5-blue)
![PHP](https://img.shields.io/badge/PHP-7.4+-purple)
![License](https://img.shields.io/badge/license-MIT-green)

Digital receipt management with admin approval workflow.
```

### Add LICENSE

```bash
# Create MIT License (common choice)
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
EOF

git add LICENSE
git commit -m "Add: MIT License"
```

### Setup GitHub Issues Templates

Create `.github/ISSUE_TEMPLATE/bug_report.md`:

```markdown
---
name: Bug Report
about: Create a report to help us improve
---

**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
 - PHP Version: [e.g. 7.4]
 - Browser: [e.g. Chrome 95]
 - OS: [e.g. Windows 10]
```

## Deployment Workflow

### Deploying to Production

```bash
# On your local machine

# 1. Ensure all changes are committed
git status  # Should be clean

# 2. Create release tag
git tag -a v3.5 -m "Release version 3.5 - PDF viewer fix + Admin error handling"

# 3. Push with tags
git push origin main --tags

# 4. On production server (SSH)
ssh user@e-receipt.lerumaenterprises.co.tz

# 5. Pull latest changes
cd /home/user/public_html/e-receipt
git pull origin main

# 6. Copy production config (first time only)
cp api/config/database.example.php api/config/database.php
nano api/config/database.php  # Edit credentials

# 7. Set permissions
chmod 755 api/uploads
find . -type f -name "*.php" -exec chmod 644 {} \;

# 8. Clear cache if needed
php -r 'opcache_reset();'
```

## Git Hooks (Optional)

### Pre-commit Hook (Prevent Committing Secrets)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

# Check if database.php is being committed
if git diff --cached --name-only | grep -q "api/config/database.php"; then
    echo "ERROR: Attempting to commit database.php with credentials!"
    echo "Please remove it from staging: git reset api/config/database.php"
    exit 1
fi

# Check for TODO/FIXME in code
if git diff --cached | grep -E "TODO|FIXME" > /dev/null; then
    echo "WARNING: You have TODO or FIXME in your code"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

exit 0
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Troubleshooting

### "fatal: not a git repository"
```bash
# You're not in the right directory
cd /Applications/XAMPP/xamppfiles/htdocs/e-receipt
git init
```

### "warning: LF will be replaced by CRLF"
```bash
# Line ending issue (Windows/Mac)
git config core.autocrlf false
```

### Accidentally Committed Sensitive File
```bash
# Remove from Git but keep local file
git rm --cached api/config/database.php
git commit -m "Remove database.php from version control"

# If already pushed to remote
# WARNING: This rewrites history!
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch api/config/database.php' \
  --prune-empty --tag-name-filter cat -- --all

git push origin --force --all
```

### Large Files Rejected by GitHub
```bash
# Check file sizes
find . -type f -size +50M

# Remove large files from history (if committed)
git filter-branch -f --index-filter \
  'git rm --cached --ignore-unmatch path/to/large/file.pdf'
```

## Summary

✅ **DO:**
- Commit all source code
- Commit documentation
- Commit database schema
- Use meaningful commit messages
- Create branches for features
- Tag releases

❌ **DON'T:**
- Commit database.php (credentials)
- Commit user uploaded files
- Commit log files
- Commit IDE configuration
- Force push to main branch
- Commit sensitive keys/tokens

---

**Need Help?**
- Git Documentation: https://git-scm.com/doc
- GitHub Guides: https://guides.github.com/
- GitLab Docs: https://docs.gitlab.com/
