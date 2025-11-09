import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'biometric_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  final BiometricService _biometric = BiometricService();

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

      // Clear cookies and local storage regardless of API response
      await _api.clearCookies();
      await _storage.clearUserData();

      return response;
    } catch (e) {
      // Still clear cookies and local storage even if API call fails
      await _api.clearCookies();
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

  // Biometric login - authenticates with biometric and logs in with saved credentials
  Future<Map<String, dynamic>> loginWithBiometric() async {
    try {
      // 1. Check if biometric is enabled
      final isBiometricEnabled = await _biometric.isBiometricEnabled();
      if (!isBiometricEnabled) {
        return {
          'success': false,
          'message': 'Biometric authentication is not enabled',
        };
      }

      // 2. Authenticate with biometric
      final authenticated = await _biometric.authenticate(
        localizedReason: 'Authenticate to login to E-Receipt',
      );

      if (!authenticated) {
        return {
          'success': false,
          'message': 'Biometric authentication failed',
        };
      }

      // 3. Get saved credentials
      final credentials = await _biometric.getSavedCredentials();
      final username = credentials['username'];
      final password = credentials['password'];

      if (username == null || password == null) {
        return {
          'success': false,
          'message': 'No saved credentials found',
        };
      }

      // 4. Login with saved credentials (generates fresh token)
      return await login(username, password);
    } catch (e) {
      return {
        'success': false,
        'message': 'Biometric login failed: ${e.toString()}',
      };
    }
  }

  // Enable biometric authentication
  Future<Map<String, dynamic>> enableBiometric({
    required String username,
    required String password,
  }) async {
    try {
      await _biometric.enableBiometric(
        username: username,
        password: password,
      );
      return {
        'success': true,
        'message': 'Biometric authentication enabled',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to enable biometric: ${e.toString()}',
      };
    }
  }

  // Disable biometric authentication
  Future<Map<String, dynamic>> disableBiometric() async {
    try {
      await _biometric.disableBiometric();
      return {
        'success': true,
        'message': 'Biometric authentication disabled',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to disable biometric: ${e.toString()}',
      };
    }
  }

  // Check if biometric is available on device
  Future<bool> isBiometricAvailable() async {
    return await _biometric.isBiometricAvailable();
  }

  // Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    return await _biometric.isBiometricEnabled();
  }

  // Get biometric type name
  Future<String> getBiometricTypeName() async {
    final types = await _biometric.getAvailableBiometrics();
    return _biometric.getBiometricTypeName(types);
  }
}
