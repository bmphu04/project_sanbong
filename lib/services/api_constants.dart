/// Cấu hình các hằng số dùng cho API.
///
/// Khi backend thật đã deploy, thay [baseUrl] bằng URL production.
class ApiConstants {
  ApiConstants._();

  /// Base URL cua backend. Khi chay tren Android emulator/VM: 10.0.2.2 => localhost.
  /// Doi sang IP LAN neu chay tren thiet bi thuc.
  static const String baseUrl = 'http://10.0.2.2:4000';

  /// Thời gian timeout cho mỗi request (giây).
  static const int timeoutSeconds = 15;
}