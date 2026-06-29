/// Response trả về khi đăng nhập thành công.
///
/// Khớp với cấu trúc JSON:
/// ```
/// {
///   "message": "Đăng nhập thành công",
///   "result": {
///     "access_token": "eyJhbG...",
///     "refresh_token": "eyJhbG..."
///   }
/// }
/// ```
class LoginResponse {
  final String message;
  final LoginResult result;

  const LoginResponse({required this.message, required this.result});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String? ?? '',
      result: LoginResult.fromJson(
        (json['result'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}

class LoginResult {
  final String accessToken;
  final String refreshToken;

  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
    );
  }
}