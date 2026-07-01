import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/booking.dart';

class AdminService {
  final ApiClient _api = ApiClient.instance;

  /// GET /admin/bookings/daily?date=YYYY-MM-DD
  Future<List<AdminBooking>> getDailyBookings({required DateTime date}) async {
    final isoDate =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      final resp = await _api.raw.get<dynamic>(
        '/admin/bookings/daily',
        queryParameters: {'date': isoDate},
      );
      final list = (resp.data['result'] as List).cast<Map<String, dynamic>>();
      return list.map(AdminBooking.fromJson).toList();
    } on DioException catch (e) {
      throw _toApi(e);
    }
  }

  /// POST /admin/bookings/force-cancel
  Future<String> forceCancel({required String bookingId, required String reason}) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/admin/bookings/force-cancel',
        data: {'booking_id': bookingId, 'reason': reason},
      );
      return resp.data['message']?.toString() ?? 'Đã hủy vé';
    } on DioException catch (e) {
      throw _toApi(e);
    }
  }

  /// GET /admin/revenue?start_date=...&end_date=...
  Future<Revenue> getRevenue({required DateTime start, required DateTime end}) async {
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    try {
      final resp = await _api.raw.get<dynamic>(
        '/admin/revenue',
        queryParameters: {'start_date': fmt(start), 'end_date': fmt(end)},
      );
      return Revenue.fromJson(resp.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(DioException e) {
    final err = e.error;
    if (err is ApiException) return err;
    return ApiException(statusCode: 0, message: 'Có lỗi xảy ra, vui lòng thử lại');
  }
}