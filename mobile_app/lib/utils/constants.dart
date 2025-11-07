import 'package:flutter/material.dart';

// API Configuration
class ApiConstants {
  // Environment URLs
  static const String prodUrl = 'https://e-receipt.lerumaenterprises.co.tz/api';
  static const String localUrl = 'http://192.168.0.100/e-receipt/api';

  // Active environment - Change this to switch between environments
  // true = Production, false = Local
  static const bool useProduction = true;

  // Base URL based on environment
  static String get baseUrl => useProduction ? prodUrl : localUrl;

  // Environment-specific configurations
  // For Android Emulator: http://10.0.2.2/e-receipt/api
  // For iOS Simulator: http://localhost/e-receipt/api
  // For Physical Device: Use your local IP or production URL

  // Auth endpoints
  static const String login = '/auth/login.php';
  static const String register = '/auth/register.php';
  static const String logout = '/auth/logout.php';

  // Receipt endpoints
  static const String uploadReceipt = '/receipts/upload.php';
  static const String userHistory = '/receipts/user-history.php';
  static const String userStatistics = '/receipts/user-statistics.php';

  // Bank endpoints
  static const String banks = '/banks/list.php';

  // Admin endpoints
  static const String adminStatistics = '/admin/statistics.php';
  static const String adminReceipts = '/admin/receipts.php';
  static const String adminUsers = '/admin/users.php';
  static const String approveReceipt = '/admin/approve-receipt.php';
}

// App Colors
class AppColors {
  static const Color primaryOrange = Color(0xFFF59E0B);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color darkBg = Color(0xFF1F1F1F);
  static const Color cardBg = Color(0xFF2A2A2A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFF374151);

  static const Color successGreen = Color(0xFF10B981);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);

  // Status colors
  static const Color statusPending = warningYellow;
  static const Color statusApproved = successGreen;
  static const Color statusRejected = dangerRed;
}

// App Theme
class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryOrange,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryOrange,
      secondary: AppColors.primaryOrange,
      surface: AppColors.cardBg,
      error: AppColors.dangerRed,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderColor, width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.dangerRed),
      ),
      labelStyle: const TextStyle(color: AppColors.lightGray),
      hintStyle: const TextStyle(color: AppColors.lightGray),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryOrange,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

// Storage Keys
class StorageKeys {
  static const String userId = 'user_id';
  static const String username = 'username';
  static const String fullName = 'full_name';
  static const String phone = 'phone';
  static const String isAdmin = 'is_admin';
  static const String isLoggedIn = 'is_logged_in';
}
