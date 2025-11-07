import '../models/bank.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class BankService {
  final ApiService _api = ApiService();

  // Get all banks (including inactive)
  Future<Map<String, dynamic>> getAllBanks() async {
    try {
      final response = await _api.get('${ApiConstants.banks}?all=true');

      if (response['success'] == true && response['data'] != null) {
        List<Bank> banks = (response['data'] as List)
            .map((json) => Bank.fromJson(json))
            .toList();

        return {
          'success': true,
          'data': banks,
        };
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load banks: ${e.toString()}',
      };
    }
  }

  // Get all active banks
  Future<Map<String, dynamic>> getActiveBanks() async {
    try {
      final response = await _api.get(ApiConstants.banks);

      if (response['success'] == true && response['data'] != null) {
        List<Bank> banks = (response['data'] as List)
            .map((json) => Bank.fromJson(json))
            .toList();

        return {
          'success': true,
          'data': banks,
        };
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load banks: ${e.toString()}',
      };
    }
  }

  // Create new bank
  Future<Map<String, dynamic>> createBank({
    required String bankName,
    String? bankCode,
  }) async {
    try {
      final response = await _api.post('/admin/bank-create.php', {
        'bank_name': bankName,
        'bank_code': bankCode,
        'status': 'active',
      });

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create bank: ${e.toString()}',
      };
    }
  }

  // Update bank
  Future<Map<String, dynamic>> updateBank({
    required int bankId,
    required String bankName,
    String? bankCode,
  }) async {
    try {
      final response = await _api.post('/admin/bank-update.php', {
        'id': bankId,
        'bank_name': bankName,
        'bank_code': bankCode,
        'status': 'active',
      });

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update bank: ${e.toString()}',
      };
    }
  }

  // Delete bank (soft delete - change status to inactive)
  Future<Map<String, dynamic>> deleteBank(int bankId) async {
    try {
      final response = await _api.post('/admin/bank-delete.php', {
        'id': bankId,
      });

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete bank: ${e.toString()}',
      };
    }
  }

  // Restore bank (change status back to active)
  Future<Map<String, dynamic>> restoreBank(int bankId) async {
    try {
      final response = await _api.post('/admin/bank-restore.php', {
        'id': bankId,
      });

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to restore bank: ${e.toString()}',
      };
    }
  }
}
