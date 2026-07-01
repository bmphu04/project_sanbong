/// Exception chuẩn hoá mọi lỗi từ BE trả về.
/// - statusCode: HTTP status (401, 422, 500...)
/// - message: message do BE trả (hoặc mặc định)
/// - fieldErrors: lỗi validate theo field (chỉ có ở status 422)
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? fieldErrors;

  ApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors,
  });

  /// Nếu là lỗi validate trên field cụ thể, lấy message đầu tiên của field đó
  String? firstFieldError(String field) {
    final errs = fieldErrors?[field];
    if (errs is Map && errs['msg'] != null) return errs['msg'].toString();
    if (errs is String) return errs;
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}