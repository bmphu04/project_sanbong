/// Cấu hình các hằng số dùng cho API.
///
/// Khi backend thật đã deploy, thay [baseUrl] bằng URL production.
class ApiConstants {
  ApiConstants._();

  /// Base URL của backend. Đổi sang production khi go-live.
  static const String baseUrl = 'https://api.example.com';

  /// Thời gian timeout cho mỗi request (giây).
  static const int timeoutSeconds = 15;
}