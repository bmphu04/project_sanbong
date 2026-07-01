import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// TokenStorage — single class with both static (for api_service/http) and
/// instance methods (for auth_provider/api_client/Dio interceptor).
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final FlutterSecureStorage _s = const FlutterSecureStorage();

  static const _kAccess  = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kEmail   = 'user_email';
  static const _kRole    = 'user_role';
  static const _kUserId  = 'user_id';

  // ---- static (called by api_service http package) ----
  static Future<void> saveAccessToken(String t) => instance._s.write(key: _kAccess, value: t);
  static Future<String?> getAccessToken()        => instance._s.read(key: _kAccess);
  static Future<void> saveRefreshToken(String t)  => instance._s.write(key: _kRefresh, value: t);
  static Future<String?> getRefreshToken()        => instance._s.read(key: _kRefresh);
  static Future<void> saveUserEmail(String e)    => instance._s.write(key: _kEmail, value: e);
  static Future<String?> getUserEmail()           => instance._s.read(key: _kEmail);
  static Future<void> saveUserRole(int r)        => instance._s.write(key: _kRole, value: r.toString());
  static Future<int?> getUserRole() async {
    final v = await instance._s.read(key: _kRole);
    return v == null ? null : int.tryParse(v);
  }
  static Future<void> saveUserId(String id)      => instance._s.write(key: _kUserId, value: id);
  static Future<String?> getUserId()             => instance._s.read(key: _kUserId);
  static Future<void> clearAll()               => instance._s.deleteAll();
  static Future<bool> isLoggedIn() async {
    final t = await getAccessToken();
    return t != null && t.isNotEmpty;
  }

  // ---- instance (called by auth_provider & api_client) ----
  Future<void> updateAccessToken(String t) => _s.write(key: _kAccess, value: t);
  Future<String?> readAccessToken()        => _s.read(key: _kAccess);
  Future<String?> readRefreshToken()        => _s.read(key: _kRefresh);
  Future<int?> readUserRole() async {
    final v = await _s.read(key: _kRole);
    return v == null ? null : int.tryParse(v);
  }
  Future<String?> readUserId() => _s.read(key: _kUserId);
  Future<void> clear()         => _s.deleteAll();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int? userRole,
    String? userId,
  }) async {
    await Future.wait([
      _s.write(key: _kAccess, value: accessToken),
      _s.write(key: _kRefresh, value: refreshToken),
      if (userRole != null) _s.write(key: _kRole, value: userRole.toString()),
      if (userId != null)  _s.write(key: _kUserId, value: userId),
    ]);
  }
}
