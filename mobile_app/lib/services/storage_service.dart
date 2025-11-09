import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Initialize storage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save user data after login
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    // Parse user ID safely
    int? userId;
    if (userData['id'] != null) {
      try {
        userId = int.parse(userData['id'].toString());
      } catch (e) {
        // If parsing fails, try to handle it as already an int
        if (userData['id'] is int) {
          userId = userData['id'];
        }
      }
    }

    if (userId != null) {
      await _prefs?.setInt(StorageKeys.userId, userId);
    }

    await _prefs?.setString(StorageKeys.username, userData['username'] ?? '');
    await _prefs?.setString(StorageKeys.fullName, userData['full_name'] ?? '');
    await _prefs?.setString(StorageKeys.phone, userData['phone'] ?? '');

    // Handle is_admin - could be bool, int, or string
    print('STORAGE DEBUG: Raw is_admin from API: ${userData['is_admin']}');
    print('STORAGE DEBUG: is_admin type: ${userData['is_admin'].runtimeType}');

    bool isAdmin = false;
    if (userData['is_admin'] != null) {
      if (userData['is_admin'] is bool) {
        isAdmin = userData['is_admin'];
      } else if (userData['is_admin'] is int) {
        isAdmin = userData['is_admin'] == 1;
      } else {
        isAdmin = userData['is_admin'].toString() == '1' ||
                  userData['is_admin'].toString().toLowerCase() == 'true';
      }
    }

    print('STORAGE DEBUG: Saving isAdmin as: $isAdmin');
    await _prefs?.setBool(StorageKeys.isAdmin, isAdmin);
    await _prefs?.setBool(StorageKeys.isLoggedIn, true);
  }

  // Get user ID
  int? getUserId() {
    return _prefs?.getInt(StorageKeys.userId);
  }

  // Get username
  String? getUsername() {
    return _prefs?.getString(StorageKeys.username);
  }

  // Get full name
  String? getFullName() {
    return _prefs?.getString(StorageKeys.fullName);
  }

  // Get phone
  String? getPhone() {
    return _prefs?.getString(StorageKeys.phone);
  }

  // Check if user is admin
  bool isAdmin() {
    return _prefs?.getBool(StorageKeys.isAdmin) ?? false;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs?.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  // Clear all user data (logout)
  // Note: This does NOT clear biometric credentials stored in FlutterSecureStorage
  // Biometric credentials persist across logout sessions for convenience
  Future<void> clearUserData() async {
    await _prefs?.remove(StorageKeys.userId);
    await _prefs?.remove(StorageKeys.username);
    await _prefs?.remove(StorageKeys.fullName);
    await _prefs?.remove(StorageKeys.phone);
    await _prefs?.remove(StorageKeys.isAdmin);
    await _prefs?.setBool(StorageKeys.isLoggedIn, false);

    print('✅ User data cleared (biometric credentials preserved)');
  }

  // Get all user data as map
  Map<String, dynamic> getUserData() {
    return {
      'id': getUserId(),
      'username': getUsername(),
      'full_name': getFullName(),
      'phone': getPhone(),
      'is_admin': isAdmin(),
    };
  }
}
