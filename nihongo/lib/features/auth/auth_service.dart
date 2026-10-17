import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/api.dart';

/// Map tu `AuthResponse` cua backend.
class AuthResult {
  const AuthResult({
    required this.token,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final String token;
  final int userId;
  final String email;
  final String? fullName;
  final String role;

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        token: json['token'] as String,
        userId: json['userId'] as int,
        email: json['email'] as String,
        fullName: json['fullName'] as String?,
        role: json['role'] as String? ?? 'user',
      );
}

/// Luu JWT va thong tin user vao secure storage (Keystore tren Android).
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _keyToken = 'auth_token';
  static const _keyEmail = 'auth_email';
  static const _keyFullName = 'auth_full_name';

  Future<void> save({
    required String token,
    required String email,
    String? fullName,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyEmail, value: email);
    if (fullName != null) {
      await _storage.write(key: _keyFullName, value: fullName);
    }
  }

  Future<String?> readToken() => _storage.read(key: _keyToken);

  Future<String?> readEmail() => _storage.read(key: _keyEmail);

  Future<String?> readFullName() => _storage.read(key: _keyFullName);

  Future<void> clear() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyFullName);
  }
}

/// Goi 4 endpoint auth cua backend va luu token sau khi dang nhap/dang ky.
class AuthService {
  AuthService({ApiClient? client, TokenStorage? storage})
      : _client = client ?? ApiClient(),
        _storage = storage ?? TokenStorage();

  final ApiClient _client;
  final TokenStorage _storage;

  TokenStorage get storage => _storage;

  Future<AuthResult> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final json = await _client.post(ApiConfig.register, {
      'email': email.trim(),
      'password': password,
      if (fullName != null && fullName.trim().isNotEmpty)
        'fullName': fullName.trim(),
    });

    return _persist(AuthResult.fromJson(json));
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post(ApiConfig.login, {
      'email': email.trim(),
      'password': password,
    });

    return _persist(AuthResult.fromJson(json));
  }

  /// Backend luon tra cung mot message du email co ton tai hay khong,
  /// de tranh lo danh sach nguoi dung.
  Future<String> forgotPassword({required String email}) async {
    final json = await _client.post(ApiConfig.forgotPassword, {
      'email': email.trim(),
    });

    return json['message'] as String? ??
        'Nếu email tồn tại, hướng dẫn đặt lại mật khẩu đã được gửi.';
  }

  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final json = await _client.post(ApiConfig.resetPassword, {
      'token': token.trim(),
      'newPassword': newPassword,
    });

    return json['message'] as String? ?? 'Đặt lại mật khẩu thành công';
  }

  Future<void> logout() => _storage.clear();

  Future<AuthResult> _persist(AuthResult result) async {
    await _storage.save(
      token: result.token,
      email: result.email,
      fullName: result.fullName,
    );
    return result;
  }

  void dispose() => _client.dispose();
}
