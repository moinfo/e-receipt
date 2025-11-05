import '../models/bank.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class BankService {
  final ApiService _api = ApiService();

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
}
