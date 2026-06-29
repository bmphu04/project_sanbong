import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lớp wrapper quanh [FlutterSecureStorage] để lưu / đọc
/// các thông tin nhạy cảm (token, refresh token, thông tin user).
///
/// Dữ liệu được mã hoá bằng:
/// - Android: EncryptedSharedPreferences (AES)
/// - iOS: Keychain
/// - macOS: Keychain
/// - Web: localStorage với mã hoá tự sinh
class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage();

  // Keys
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserEmail = 'user_email';

  // ---------- Access token ----------
  static Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  static Future<String?> getAccessToken() =>
      _storage.read(key: _kAccessToken);

  // ---------- Refresh token ----------
  static Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _kRefreshToken, value: token);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _kRefreshToken);

  // ---------- User info ----------
  static Future<void> saveUserEmail(String email) =>
      _storage.write(key: _kUserEmail, value: email);

  static Future<String?> getUserEmail() => _storage.read(key: _kUserEmail);

  // ---------- Helpers ----------
  /// Xoá toàn bộ token + thông tin user (dùng khi đăng xuất).
  static Future<void> clearAll() => _storage.deleteAll();

  /// Kiểm tra đã đăng nhập hay chưa (có access token).
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}