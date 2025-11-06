import '../models/user.dart';
import '../models/receipt.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _api = ApiService();

  // Get pending users
  Future<Map<String, dynamic>> getPendingUsers() async {
    try {
      final response = await _api.get('${ApiConstants.adminUsers}?status=pending');

      if (response['success'] == true && response['data'] != null) {
        List<User> users = (response['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();

        return {
          'success': true,
          'data': users,
        };
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load pending users: ${e.toString()}',
      };
    }
  }

  // Get all users
  Future<Map<String, dynamic>> getAllUsers({String? status}) async {
    try {
      String url = ApiConstants.adminUsers;
      if (status != null) {
        url += '?status=$status';
      }

      final response = await _api.get(url);

      if (response['success'] == true && response['data'] != null) {
        List<User> users = (response['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();

        return {
          'success': true,
          'data': users,
        };
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load users: ${e.toString()}',
      };
    }
  }

  // Approve or reject user
  Future<Map<String, dynamic>> updateUserStatus(int userId, String status) async {
    try {
      final response = await _api.post('${ApiConstants.adminUsers}/update-status.php', {
        'user_id': userId,
        'status': status,
      });

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update user status: ${e.toString()}',
      };
    }
  }

  // Get all receipts (admin view)
  Future<Map<String, dynamic>> getAllReceipts({
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      String url = ApiConstants.adminReceipts;
      List<String> params = [];

      if (status != null) params.add('status=$status');
      if (dateFrom != null) params.add('date_from=$dateFrom');
      if (dateTo != null) params.add('date_to=$dateTo');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await _api.get(url);

      if (response['success'] == true && response['data'] != null) {
        List<Receipt> receipts = (response['data'] as List)
            .map((json) => Receipt.fromJson(json))
            .toList();

        return {
          'success': true,
          'data': receipts,
        };
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load receipts: ${e.toString()}',
      };
    }
  }

  // Approve or reject receipt
  Future<Map<String, dynamic>> updateReceiptStatus(int receiptId, String status) async {
    try {
      final response = await _api.post(ApiConstants.approveReceipt, {
        'receipt_id': receiptId,
        'status': status,
      });

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update receipt status: ${e.toString()}',
      };
    }
  }
}
