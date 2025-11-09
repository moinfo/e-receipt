import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys for biometric data
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyBiometricUsername = 'biometric_username';
  static const String _keyBiometricPassword = 'biometric_password';

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      print('🔍 Device supported: $canAuthenticate');
      return canAuthenticate;
    } catch (e) {
      print('❌ Error checking device support: $e');
      return false;
    }
  }

  /// Check if biometrics are available (enrolled)
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      print('🔍 Can check biometrics: $canCheckBiometrics');

      if (!canCheckBiometrics) {
        return false;
      }

      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      print('🔍 Available biometric types: $availableBiometrics');

      return availableBiometrics.isNotEmpty;
    } catch (e) {
      print('❌ Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('❌ Error getting biometric types: $e');
      return [];
    }
  }

  /// Authenticate user with biometric
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      print('🔐 Biometric authentication result: $didAuthenticate');
      return didAuthenticate;
    } on Exception catch (e) {
      print('❌ Biometric authentication error: $e');

      // Handle specific error cases
      if (e.toString().contains(auth_error.notAvailable)) {
        print('❌ Biometric not available');
      } else if (e.toString().contains(auth_error.notEnrolled)) {
        print('❌ No biometrics enrolled');
      } else if (e.toString().contains(auth_error.lockedOut) ||
                 e.toString().contains(auth_error.permanentlyLockedOut)) {
        print('❌ Biometric locked out');
      }

      return false;
    }
  }

  /// Enable biometric authentication and save credentials
  Future<void> enableBiometric({
    required String username,
    required String password,
  }) async {
    try {
      await _secureStorage.write(key: _keyBiometricEnabled, value: 'true');
      await _secureStorage.write(key: _keyBiometricUsername, value: username);
      await _secureStorage.write(key: _keyBiometricPassword, value: password);
      print('✅ Biometric credentials saved');
    } catch (e) {
      print('❌ Failed to save biometric credentials: $e');
      rethrow;
    }
  }

  /// Disable biometric authentication and clear credentials
  Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _keyBiometricEnabled);
      await _secureStorage.delete(key: _keyBiometricUsername);
      await _secureStorage.delete(key: _keyBiometricPassword);
      print('✅ Biometric credentials cleared');
    } catch (e) {
      print('❌ Failed to clear biometric credentials: $e');
      rethrow;
    }
  }

  /// Check if biometric is currently enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final String? enabled = await _secureStorage.read(key: _keyBiometricEnabled);
      final bool isEnabled = enabled == 'true';
      print('🔍 Biometric enabled in storage: $isEnabled');
      return isEnabled;
    } catch (e) {
      print('❌ Error checking biometric enabled status: $e');
      return false;
    }
  }

  /// Get saved credentials (requires prior biometric authentication)
  Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final username = await _secureStorage.read(key: _keyBiometricUsername);
      final password = await _secureStorage.read(key: _keyBiometricPassword);

      if (username != null && password != null) {
        print('✅ Retrieved saved credentials');
        return {
          'username': username,
          'password': password,
        };
      } else {
        print('❌ No saved credentials found');
        return {
          'username': null,
          'password': null,
        };
      }
    } catch (e) {
      print('❌ Error getting saved credentials: $e');
      return {
        'username': null,
        'password': null,
      };
    }
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong) || types.contains(BiometricType.weak)) {
      return 'Biometric';
    }
    return 'Biometric';
  }
}
