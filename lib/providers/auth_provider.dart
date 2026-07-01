import 'package:flutter/foundation.dart';
import '../core/storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

/// Provider quản lý state đăng nhập hiện tại của user.
/// - Khi mở app: đọc token từ SecureStorage, nếu có thì gọi /users/me để xác thực
/// - Sau khi login: lưu token, lưu user_info, notify listeners
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  final TokenStorage _storage = TokenStorage.instance;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _error;
  bool _loading = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Khởi tạo app: kiểm tra đã có token chưa
  Future<void> bootstrap() async {
    final access = await _storage.readAccessToken();
    if (access == null || access.isEmpty) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      final u = await _service.getMe();
      _user = u;
      _status = AuthStatus.authenticated;
    } catch (_) {
      // Token lỗi → interceptor đã refresh xong, fail thì clear
      await _storage.clear();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final tokens = await _service.login(email: email, password: password);
      await _storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      // Lấy profile ngay để biết role
      final u = await _service.getMe();
      await _storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        userRole: u.userRole,
        userId: u.id,
      );
      _user = u;
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('ApiException(0): ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      final rt = await _storage.readRefreshToken();
      if (rt != null && rt.isNotEmpty) {
        try {
          await _service.logout(refreshToken: rt);
        } catch (_) {}
      }
    } finally {
      await _storage.clear();
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    try {
      _user = await _service.getMe();
      notifyListeners();
    } catch (_) {}
  }
}