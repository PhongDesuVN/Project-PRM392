import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Cau hinh endpoint cua backend Spring Boot.
///
/// Android emulator khong truy cap duoc `localhost` cua may host,
/// `10.0.2.2` la alias ma emulator dung de tro ve host.
/// Neu chay tren may that, doi thanh IP LAN cua may chay backend.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = 'http://10.0.2.2:8080';
  static const Duration timeout = Duration(seconds: 15);

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String dictionarySearch = '/dictionary/search';
  static const String alphabet = '/alphabet';
  static const String topics = '/topics';
  static const String notebookSync = '/notebook/sync';
  static const String notebookStats = '/notebook/stats';
  static const String notebookWords = '/notebook/words';
  static const String notebookList = '/notebook/list';
  static const String notebook = '/notebook';
  static const String searchHistory = '/search-history';
  static const String mockExam = '/mock-exam';
}

/// Loi phat sinh khi goi API, kem message da san sang hien thi cho nguoi dung.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.fieldErrors});

  final String message;
  final int? statusCode;

  /// Loi theo tung field tu `GlobalExceptionHandler` cua backend,
  /// vi du `{"email": "Email khong hop le"}`.
  final Map<String, String>? fieldErrors;

  @override
  String toString() => message;
}

/// Wrapper quanh `http` de gom logic encode/decode JSON va map loi
/// tu backend thanh [ApiException].
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  static String? defaultUserEmail;
  static int? defaultUserId;
  static String? defaultAuthToken;

  final http.Client _client;

  /// Mac dinh la [ApiConfig.baseUrl]. Cho phep override de goi tu may host
  /// (localhost) thay vi tu emulator (10.0.2.2).
  final String _baseUrl;

  static const _networkError =
      'Không kết nối được tới server. Kiểm tra backend đã chạy chưa.';

  Map<String, String> _buildHeaders({
    String? contentType,
    String? bearerToken,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    if (defaultUserEmail != null) {
      headers['X-User-Email'] = defaultUserEmail!;
    }
    if (defaultUserId != null) {
      headers['X-User-Id'] = defaultUserId!.toString();
    }
    final effectiveToken = bearerToken ?? defaultAuthToken;
    if (effectiveToken != null) {
      headers['Authorization'] = 'Bearer $effectiveToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String> queryParameters = const {},
    String? bearerToken,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(bearerToken: bearerToken),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(_networkError);
    } on http.ClientException {
      throw ApiException(_networkError);
    } on TimeoutException {
      throw ApiException('Server phản hồi quá lâu. Vui lòng thử lại.');
    } on FormatException {
      throw ApiException('Dữ liệu trả về không hợp lệ.');
    }
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String> queryParameters = const {},
    String? bearerToken,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(bearerToken: bearerToken),
          )
          .timeout(ApiConfig.timeout);

      final rawBody = utf8.decode(response.bodyBytes);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (rawBody.isEmpty) return [];
        final decoded = jsonDecode(rawBody);
        if (decoded is List) {
          return decoded;
        }
        return [];
      }
      throw ApiException('Lỗi tải dữ liệu.');
    } on SocketException {
      throw ApiException(_networkError);
    } on http.ClientException {
      throw ApiException(_networkError);
    } on TimeoutException {
      throw ApiException('Server phản hồi quá lâu. Vui lòng thử lại.');
    } on FormatException {
      throw ApiException('Dữ liệu trả về không hợp lệ.');
    }
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: _buildHeaders(
              contentType: 'application/json; charset=utf-8',
              bearerToken: bearerToken,
            ),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(_networkError);
    } on http.ClientException {
      // Tren Android, loi mang thuong duoc goi lai thanh ClientException.
      throw ApiException(_networkError);
    } on TimeoutException {
      throw ApiException('Server phản hồi quá lâu. Vui lòng thử lại.');
    } on FormatException {
      throw ApiException('Dữ liệu trả về không hợp lệ.');
    }
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl$path'),
            headers: _buildHeaders(
              contentType: 'application/json; charset=utf-8',
              bearerToken: bearerToken,
            ),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(_networkError);
    } on http.ClientException {
      throw ApiException(_networkError);
    } on TimeoutException {
      throw ApiException('Server phản hồi quá lâu. Vui lòng thử lại.');
    } on FormatException {
      throw ApiException('Dữ liệu trả về không hợp lệ.');
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    String? bearerToken,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$_baseUrl$path'),
            headers: _buildHeaders(
              contentType: 'application/json; charset=utf-8',
              bearerToken: bearerToken,
            ),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(_networkError);
    } on http.ClientException {
      throw ApiException(_networkError);
    } on TimeoutException {
      throw ApiException('Server phản hồi quá lâu. Vui lòng thử lại.');
    } on FormatException {
      throw ApiException('Dữ liệu trả về không hợp lệ.');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    // Backend tra UTF-8; dung utf8.decode de khong hong tieng Viet.
    final rawBody = utf8.decode(response.bodyBytes);

    Map<String, dynamic> json = <String, dynamic>{};
    if (rawBody.isNotEmpty) {
      final decoded = jsonDecode(rawBody);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException('Dữ liệu trả về không hợp lệ.');
      }
      json = decoded;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }

    // GlobalExceptionHandler tra ve {timestamp, status, message, errors?}
    final errors = json['errors'];
    throw ApiException(
      json['message'] as String? ?? 'Đã có lỗi xảy ra.',
      statusCode: response.statusCode,
      fieldErrors: errors is Map
          ? errors.map((k, v) => MapEntry(k.toString(), v.toString()))
          : null,
    );
  }

  void dispose() => _client.close();
}
