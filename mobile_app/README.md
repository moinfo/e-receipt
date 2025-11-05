# E-Receipt Mobile App

Flutter mobile application for the E-Receipt Management System.

## Features

- **User Authentication**
  - Login with username and password
  - Self-registration with admin approval workflow
  - Secret question for password recovery

- **Receipt Management**
  - Upload receipts (images or PDFs up to 10MB)
  - Camera integration for quick photo capture
  - View receipt history with date range filters
  - Real-time status tracking (pending/approved/rejected)

- **Dashboard**
  - Today's statistics overview
  - Total receipts count by status
  - Total approved amount
  - Quick action buttons

- **Beautiful UI**
  - Dark theme with orange accent
  - Responsive design
  - Smooth animations
  - Material Design 3

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS development: Xcode (Mac only)
- Running E-Receipt API backend

## Installation

### 1. Install Flutter

Follow the official Flutter installation guide:
https://docs.flutter.dev/get-started/install

### 2. Clone or Navigate to Project

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/e-receipt/mobile_app
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure API Base URL

Edit `lib/utils/constants.dart` and set your API base URL:

```dart
class ApiConstants {
  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2/e-receipt/api';

  // For iOS Simulator
  // static const String baseUrl = 'http://localhost/e-receipt/api';

  // For Physical Device (replace with your computer's IP)
  // static const String baseUrl = 'http://192.168.1.100/e-receipt/api';
}
```

#### Finding Your Local IP Address:

**macOS:**
```bash
ipconfig getifaddr en0
```

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" under your active network adapter.

**Linux:**
```bash
ip addr show
```

### 5. iOS Setup (Mac only)

```bash
cd ios
pod install
cd ..
```

### 6. Android Permissions

The app requires the following permissions (already configured):
- Camera
- Storage (for picking images/PDFs)
- Internet

## Running the App

### Android Emulator

1. Start Android Emulator from Android Studio
2. Run:
```bash
flutter run
```

### iOS Simulator (Mac only)

1. Open iOS Simulator
2. Run:
```bash
flutter run
```

### Physical Device

1. Enable USB debugging (Android) or Developer mode (iOS)
2. Connect device via USB
3. Run:
```bash
flutter run
```

## Building Release APK (Android)

```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## Building iOS App (Mac only)

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode and archive the app.

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── receipt.dart
│   └── bank.dart
├── services/                 # Business logic & API
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── receipt_service.dart
│   ├── bank_service.dart
│   └── storage_service.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── home/
│       ├── dashboard_screen.dart
│       ├── upload_receipt_screen.dart
│       ├── history_screen.dart
│       └── receipt_detail_screen.dart
├── widgets/                  # Reusable widgets
│   ├── stat_card.dart
│   └── receipt_card.dart
└── utils/                    # Constants & helpers
    └── constants.dart
```

## Troubleshooting

### Network Connection Issues

1. **Android Emulator can't connect to localhost:**
   - Use `10.0.2.2` instead of `localhost` in API base URL
   - Make sure XAMPP Apache is running

2. **Physical Device can't connect:**
   - Ensure device is on same WiFi network as your computer
   - Use your computer's local IP address (e.g., `http://192.168.1.100/e-receipt/api`)
   - Check firewall settings

3. **iOS Simulator connection issues:**
   - Use `localhost` in API base URL
   - Make sure XAMPP is running

### Image Picker Issues

If image picker doesn't work:

**iOS:** Add these to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload receipts</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take receipt photos</string>
```

**Android:** Permissions are already configured in `android/app/src/main/AndroidManifest.xml`

### Build Issues

1. Clean the project:
```bash
flutter clean
flutter pub get
```

2. Update Flutter:
```bash
flutter upgrade
```

3. Check for platform-specific issues:
```bash
flutter doctor
```

## Default Login Credentials

Use the admin account created via the web interface:
- Username: `admin`
- Password: `admin123`

Or register a new user account (requires admin approval).

## Color Scheme

- Primary Orange: #F59E0B
- Dark Background: #1F1F1F
- Card Background: #2A2A2A
- Light Gray: #9CA3AF
- Success Green: #10B981
- Danger Red: #EF4444

## Dependencies

Key packages used:
- `http` - API calls
- `shared_preferences` - Local storage
- `image_picker` - Camera & gallery access
- `file_picker` - File selection
- `provider` - State management
- `intl` - Date/time formatting
- `permission_handler` - Runtime permissions

## API Endpoints Used

- `POST /auth/login.php` - User login
- `POST /auth/register.php` - User registration
- `POST /auth/logout.php` - User logout
- `GET /banks/list.php` - Get active banks
- `POST /receipts/upload.php` - Upload receipt
- `GET /receipts/user-history.php` - Get user receipts
- `GET /receipts/user-statistics.php` - Get user statistics

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify backend API is running correctly
3. Check Flutter doctor output: `flutter doctor -v`

## License

Copyright © 2025 E-Receipt System. All rights reserved.
