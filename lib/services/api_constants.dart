/// Cấu hình các hằng số dùng cho API.
///
/// Backend đang chạy ở port 4000. Thay [serverIp] bằng IP thật
/// của máy chủ backend trong mạng LAN của bạn.
class ApiConstants {
  ApiConstants._();

  /// IP của máy chủ backend. Ví dụ: '192.168.1.10' hoặc '10.0.2.2'
  /// (10.0.2.2 là host máy thật khi dùng Android Emulator).
  static const String serverIp = '<IP_MAY_SERVER>';

  /// Base URL của backend, ví dụ: `http://192.168.1.10:4000`.
  static const String baseUrl = 'http://$serverIp:4000';

  /// Thời gian timeout cho mỗi request (giây).
  static const int timeoutSeconds = 15;
}