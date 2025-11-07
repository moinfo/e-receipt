import 'dart:io';
import '../models/receipt.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class ReceiptService {
  final ApiService _api = ApiService();

  // Upload receipt
  Future<Map<String, dynamic>> uploadReceipt({
    required File receiptImage,
    required int bankId,
    required double amount,
    String? receiptNumber,
    String? description,
  }) async {
    try {
      final response = await _api.uploadFile(
        ApiConstants.uploadReceipt,
        receiptImage,
        'receipt_image',
        {
          'bank_id': bankId.toString(),
          'amount': amount.toString(),
          if (receiptNumber != null) 'receipt_number': receiptNumber,
          if (description != null) 'description': description,
        },
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Upload failed: ${e.toString()}',
      };
    }
  }

  // Get user receipt history
  Future<Map<String, dynamic>> getUserHistory({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      Map<String, String> params = {};

      if (dateFrom != null) params['date_from'] = dateFrom;
      if (dateTo != null) params['date_to'] = dateTo;

      final response = await _api.get(
        ApiConstants.userHistory,
        queryParams: params.isNotEmpty ? params : null,
      );

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
        'message': 'Failed to load history: ${e.toString()}',
      };
    }
  }

  // Get user statistics (works for both admin and regular users)
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final response = await _api.get(ApiConstants.adminStatistics);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load statistics: ${e.toString()}',
      };
    }
  }

  // Get receipt image URL
  String getReceiptImageUrl(String imagePath) {
    // Remove leading slash from imagePath if present to avoid double slashes
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;

    // Get base URL - keep /api in the path since uploads are in /api/uploads/
    final baseUrl = ApiConstants.baseUrl;

    // Construct full URL
    final fullUrl = '$baseUrl/$cleanPath';

    // Debug print
    print('Image URL constructed: $fullUrl');

    return fullUrl;
  }
}
