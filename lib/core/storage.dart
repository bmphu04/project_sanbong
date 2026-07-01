import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper quanh FlutterSecureStorage để lưu 3 key quan trọng:
/// - access_token (sống 30 phút)
/// - refresh_token (sống 7 ngày)
/// - user_role (cache tạm để check admin nhanh)
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'user_role';
  static const _userIdKey = 'user_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int? userRole,
    String? userId,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
      if (userRole != null) _storage.write(key: _roleKey, value: userRole.toString()),
      if (userId != null) _storage.write(key: _userIdKey, value: userId),
    ]);
  }

  Future<void> updateAccessToken(String accessToken) =>
      _storage.write(key: _accessKey, value: accessToken);

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<int?> readUserRole() async {
    final v = await _storage.read(key: _roleKey);
    return v == null ? null : int.tryParse(v);
  }

  Future<String?> readUserId() => _storage.read(key: _userIdKey);

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _roleKey),
      _storage.delete(key: _userIdKey),
    ]);
  }
}