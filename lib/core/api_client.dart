import 'dart:async';
import 'package:dio/dio.dart';
import 'api_exception.dart';
import 'storage.dart';

/// ApiClient: Dio instance + Interceptor tu dong refresh token.
///
/// Co che hoat dong:
/// - Moi request co header Authorization: Bearer &lt;access_token&gt;
/// - Khi server tra 401: tu goi POST /users/refresh-token de lay access_token moi
/// - Thay token cu, replay lai request cu
/// - Neu refresh cung fail: clear storage, throw exception
class ApiClient {
  ApiClient._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            contentType: 'application/json',
            responseType: ResponseType.json,
          ),
        ) {
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }

  static final ApiClient instance = ApiClient._internal();

  /// ⚠️ CHÚ Ý: Khi chạy trên máy ảo Android, host machine là 10.0.2.2.
  /// Đổi sang IP LAN thực nếu chạy trên thiết bị thật.
  static const String baseUrl = 'http://10.0.2.2:4000';

  final Dio _dio;
  final TokenStorage _storage = TokenStorage.instance;

  /// Single-flight guard: tránh gọi refresh nhiều lần song song.
  Completer<String?>? _refreshing;

  Dio get raw => _dio;

  // ===========================================================================
  // INTERCEPTORS
  // ===========================================================================

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Tự động gắn Bearer nếu là API cần auth
        final skipAuth = options.extra['skipAuth'] == true;
        if (!skipAuth) {
          final token = await _storage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        final status = err.response?.statusCode;
        final isAuthCall = err.requestOptions.extra['skipAuth'] == true ||
            err.requestOptions.path.contains('/refresh-token');

        // Chỉ xử lý 401 và KHÔNG phải chính cuộc gọi refresh
        if (status == 401 && !isAuthCall) {
          try {
            final newToken = await _refreshToken();
            if (newToken != null) {
              // Replay lại request với token mới
              final req = err.requestOptions;
              req.headers['Authorization'] = 'Bearer $newToken';
              final response = await _dio.fetch<dynamic>(req);
              return handler.resolve(response);
            }
          } catch (_) {
            // Refresh fail: rơi xuống handler.next để throw ra ngoài
          }
        }
        handler.next(err);
      },
    );
  }

  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (err, handler) {
        final response = err.response;
        if (response != null) {
          final data = response.data;
          String message = 'Có lỗi xảy ra, vui lòng thử lại';
          Map<String, dynamic>? fieldErrors;

          if (data is Map<String, dynamic>) {
            message = (data['message'] ?? message).toString();
            if (data['errors'] is Map) {
              fieldErrors = Map<String, dynamic>.from(data['errors'] as Map);
            }
          }
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: response,
              type: err.type,
              error: ApiException(
                statusCode: response.statusCode ?? 500,
                message: message,
                fieldErrors: fieldErrors,
              ),
            ),
          );
          return;
        }
        // Lỗi mạng
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            type: err.type,
            error: ApiException(
              statusCode: 0,
              message: _mapNetworkError(err),
            ),
          ),
        );
      },
    );
  }

  String _mapNetworkError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối quá chậm, vui lòng thử lại';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối tới máy chủ';
      default:
        return err.message ?? 'Có lỗi xảy ra, vui lòng thử lại';
    }
  }

  // ===========================================================================
  // REFRESH LOGIC
  // ===========================================================================

  Future<String?> _refreshToken() async {
    if (_refreshing != null) return _refreshing!.future;

    final completer = Completer<String?>();
    _refreshing = completer;
    try {
      final refresh = await _storage.readRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        await _storage.clear();
        completer.complete(null);
        return null;
      }
      final resp = await _dio.post<dynamic>(
        '/users/refresh-token',
        data: {'refresh_token': refresh},
        options: Options(extra: {'skipAuth': true}),
      );
      final newAccess = (resp.data['result'] as Map?)?['access_token'] as String?;
      if (newAccess == null) {
        await _storage.clear();
        completer.complete(null);
      } else {
        await _storage.updateAccessToken(newAccess);
        completer.complete(newAccess);
      }
    } catch (_) {
      await _storage.clear();
      completer.complete(null);
    } finally {
      _refreshing = null;
    }
    return completer.future.then((value) => value);
  }

  // ===========================================================================
  // HELPERS – unwrap response từ {message, result}
  // ===========================================================================

  T unwrap<T>(Response<dynamic> response) {
    final data = response.data;
    if (data is Map && data.containsKey('result')) {
      return data['result'] as T;
    }
    return data as T;
  }

  /// Helper bóc tách message từ response
  String? messageOf(Response<dynamic> response) {
    final data = response.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    return null;
  }
}