import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _api.post(ApiConstants.login, {
        'username': username,
        'password': password,
      });

      if (response['success'] == true && response['data'] != null) {
        // Save user data to local storage
        await _storage.saveUserData(response['data']);
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phone,
    required String username,
    required String password,
    required String secretQuestion,
    required String secretAnswer,
  }) async {
    try {
      final response = await _api.post(ApiConstants.register, {
        'full_name': fullName,
        'phone': phone,
        'username': username,
        'password': password,
        'secret_question': secretQuestion,
        'secret_answer': secretAnswer,
      });

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _api.post(ApiConstants.logout, {});

      // Clear local storage regardless of API response
      await _storage.clearUserData();

      return response;
    } catch (e) {
      // Still clear local storage even if API call fails
      await _storage.clearUserData();

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _storage.isLoggedIn();
  }

  // Get current user data
  Map<String, dynamic> getCurrentUser() {
    return _storage.getUserData();
  }

  // Check if current user is admin
  bool isAdmin() {
    return _storage.isAdmin();
  }
}
