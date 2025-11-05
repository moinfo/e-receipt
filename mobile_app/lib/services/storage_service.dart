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
    await _prefs?.setInt(StorageKeys.userId, int.parse(userData['id'].toString()));
    await _prefs?.setString(StorageKeys.username, userData['username'] ?? '');
    await _prefs?.setString(StorageKeys.fullName, userData['full_name'] ?? '');
    await _prefs?.setString(StorageKeys.phone, userData['phone'] ?? '');
    await _prefs?.setBool(StorageKeys.isAdmin, userData['is_admin'].toString() == '1');
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
  Future<void> clearUserData() async {
    await _prefs?.remove(StorageKeys.userId);
    await _prefs?.remove(StorageKeys.username);
    await _prefs?.remove(StorageKeys.fullName);
    await _prefs?.remove(StorageKeys.phone);
    await _prefs?.remove(StorageKeys.isAdmin);
    await _prefs?.setBool(StorageKeys.isLoggedIn, false);
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
