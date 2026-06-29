import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import 'api_constants.dart';
import 'token_storage.dart';

/// Kết quả trả về từ API call.
/// - [success]: request thành công (status 2xx)
/// - [data]: payload đã parse (nếu có)
/// - [error]: thông báo lỗi để hiển thị cho người dùng
class ApiResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  const ApiResult({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResult.ok(T data, {int? statusCode}) =>
      ApiResult(success: true, data: data, statusCode: statusCode);

  factory ApiResult.fail(String error, {int? statusCode}) =>
      ApiResult(success: false, error: error, statusCode: statusCode);
}

/// Service gọi các endpoint của backend.
///
/// Mọi API call của app nên đi qua class này để:
/// - Tự động đính kèm `Authorization: Bearer <access_token>` (nếu đã đăng nhập)
/// - Có timeout thống nhất
/// - Parse response / error theo cùng một cách
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  final http.Client _client = http.Client();

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  // ============================================================
  //  AUTH
  // ============================================================

  /// Đăng nhập với email + password.
  ///
  /// Endpoint: `POST /users/login`
  ///
  /// Khi thành công sẽ tự động lưu 2 token vào [TokenStorage].
  Future<ApiResult<LoginResponse>> login(LoginRequest req) async {
    try {
      final res = await _client
          .post(
            _uri('/users/login'),
            headers: _headers(),
            body: jsonEncode(req.toJson()),
          )
          .timeout(Duration(seconds: ApiConstants.timeoutSeconds));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final data = LoginResponse.fromJson(json);

        // Lưu token vào secure storage
        await TokenStorage.saveAccessToken(data.result.accessToken);
        await TokenStorage.saveRefreshToken(data.result.refreshToken);
        await TokenStorage.saveUserEmail(req.email);

        return ApiResult.ok(data, statusCode: res.statusCode);
      }

      // Lỗi từ server - thử đọc message
      String message = _extractErrorMessage(res.body) ??
          'Đăng nhập thất bại (${res.statusCode})';
      return ApiResult.fail(message, statusCode: res.statusCode);
    } on SocketException {
      return ApiResult.fail(
          'Không có kết nối mạng. Vui lòng kiểm tra Internet.');
    } on HttpException {
      return ApiResult.fail('Lỗi HTTP từ server.');
    } on FormatException {
      return ApiResult.fail('Phản hồi từ server không hợp lệ.');
    } catch (e) {
      return ApiResult.fail('Đã xảy ra lỗi: $e');
    }
  }

  /// Đăng xuất: xoá toàn bộ token đã lưu.
  Future<void> logout() => TokenStorage.clearAll();

  // ============================================================
  //  Helpers
  // ============================================================

  /// Thử lấy message lỗi từ response body (hỗ trợ nhiều format).
  String? _extractErrorMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        // Thử các key phổ biến
        for (final key in ['message', 'error', 'detail', 'msg']) {
          final v = json[key];
          if (v is String && v.isNotEmpty) return v;
        }
      }
    } catch (_) {
      // body không phải JSON -> trả về nguyên văn
      if (body.isNotEmpty) return body;
    }
    return null;
  }

  void dispose() => _client.close();
}