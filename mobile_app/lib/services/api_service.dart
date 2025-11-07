import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cookie_jar/cookie_jar.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final CookieJar _cookieJar = CookieJar();

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Get cookies for a specific URI
  Future<String> _getCookieHeader(Uri uri) async {
    final cookies = await _cookieJar.loadForRequest(uri);
    if (cookies.isEmpty) return '';
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  // Save cookies from response
  Future<void> _saveCookies(Uri uri, http.Response response) async {
    final cookieHeader = response.headers['set-cookie'];
    if (cookieHeader != null) {
      final cookies = cookieHeader.split(',').map((str) {
        return Cookie.fromSetCookieValue(str.trim());
      }).toList();
      await _cookieJar.saveFromResponse(uri, cookies);
    }
  }

  // Make GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      String url = ApiConstants.baseUrl + endpoint;

      if (queryParams != null && queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '?$queryString';
      }

      final uri = Uri.parse(url);
      final cookieHeader = await _getCookieHeader(uri);

      final headers = Map<String, String>.from(_headers);
      if (cookieHeader.isNotEmpty) {
        headers['Cookie'] = cookieHeader;
      }

      final response = await http.get(
        uri,
        headers: headers,
      );

      await _saveCookies(uri, response);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Make POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse(ApiConstants.baseUrl + endpoint);
      final cookieHeader = await _getCookieHeader(uri);

      final headers = Map<String, String>.from(_headers);
      if (cookieHeader.isNotEmpty) {
        headers['Cookie'] = cookieHeader;
      }

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );

      await _saveCookies(uri, response);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Make PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse(ApiConstants.baseUrl + endpoint);
      final cookieHeader = await _getCookieHeader(uri);

      final headers = Map<String, String>.from(_headers);
      if (cookieHeader.isNotEmpty) {
        headers['Cookie'] = cookieHeader;
      }

      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );

      await _saveCookies(uri, response);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Make DELETE request
  Future<Map<String, dynamic>> delete(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse(ApiConstants.baseUrl + endpoint);
      final cookieHeader = await _getCookieHeader(uri);

      final headers = Map<String, String>.from(_headers);
      if (cookieHeader.isNotEmpty) {
        headers['Cookie'] = cookieHeader;
      }

      final response = await http.delete(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );

      await _saveCookies(uri, response);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Upload file with multipart request
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file,
    String fieldName,
    Map<String, String> additionalFields,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.baseUrl + endpoint),
      );

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      // Add additional fields
      request.fields.addAll(additionalFields);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Request failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response: ${e.toString()}',
      };
    }
  }

  // Handle errors
  Map<String, dynamic> _handleError(dynamic error) {
    String message = 'An error occurred';

    if (error is SocketException) {
      message = 'No internet connection';
    } else if (error is HttpException) {
      message = 'HTTP error occurred';
    } else if (error is FormatException) {
      message = 'Bad response format';
    } else {
      message = error.toString();
    }

    return {
      'success': false,
      'message': message,
    };
  }
}
