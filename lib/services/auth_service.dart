import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/user.dart';
import 'package:dio/dio.dart' as dio;

class AuthService {
  final ApiClient _api = ApiClient.instance;

  // ===========================================================================
  // POST /users/register
  // ===========================================================================
  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/users/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
        },
        options: dio.Options(extra: {'skipAuth': true}),
      );
      return _api.messageOf(resp) ?? 'Đăng ký thành công. Vui lòng kiểm tra email để lấy mã OTP';
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // ===========================================================================
  // POST /users/verify-otp
  // ===========================================================================
  Future<String> verifyOtp({required String email, required String otpCode}) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/users/verify-otp',
        data: {'email': email, 'otpCode': otpCode},
        options: dio.Options(extra: {'skipAuth': true}),
      );
      return _api.messageOf(resp) ?? 'Xác thực email thành công!';
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // ===========================================================================
  // POST /users/login
  // ===========================================================================
  Future<AuthTokens> login({required String email, required String password}) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/users/login',
        data: {'email': email, 'password': password},
        options: dio.Options(extra: {'skipAuth': true}),
      );
      final result = resp.data['result'] as Map<String, dynamic>;
      return AuthTokens.fromJson(result);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // ===========================================================================
  // POST /users/logout
  // ===========================================================================
  Future<String> logout({required String refreshToken}) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/users/logout',
        data: {'refresh_token': refreshToken},
      );
      return _api.messageOf(resp) ?? 'Đăng xuất thành công';
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // ===========================================================================
  // GET /users/me
  // ===========================================================================
  Future<User> getMe() async {
    try {
      final resp = await _api.raw.get<dynamic>('/users/me');
      final data = resp.data['result'] as Map<String, dynamic>;
      return User.fromJson(data);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // ===========================================================================
  // POST /users/forgot-password
  // ===========================================================================
  Future<String> forgotPassword({required String email}) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/users/forgot-password',
        data: {'email': email},
        options: dio.Options(extra: {'skipAuth': true}),
      );
      return _api.messageOf(resp) ?? 'Mã OTP đã được gửi tới email';
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // ===========================================================================
  // POST /users/reset-password
  // ===========================================================================
  Future<String> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/users/reset-password',
        data: {
          'email': email,
          'otpCode': otpCode,
          'password': newPassword,
        },
        options: dio.Options(extra: {'skipAuth': true}),
      );
      return _api.messageOf(resp) ?? 'Đặt lại mật khẩu thành công!';
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final err = e.error;
    if (err is ApiException) return err;
    return ApiException(statusCode: 0, message: 'Có lỗi xảy ra, vui lòng thử lại');
  }
}