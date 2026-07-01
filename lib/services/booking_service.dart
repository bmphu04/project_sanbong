import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/booking.dart';

class BookingService {
  final ApiClient _api = ApiClient.instance;

  /// GET /bookings/busy-slots?field_id=...&date=YYYY-MM-DD
  Future<List<BusySlot>> getBusySlots({required String fieldId, required DateTime date}) async {
    final isoDate =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      final resp = await _api.raw.get<dynamic>(
        '/bookings/busy-slots',
        queryParameters: {'field_id': fieldId, 'date': isoDate},
        options: dio.Options(extra: {'skipAuth': true}),
      );
      final list = (resp.data['result'] as List).cast<Map<String, dynamic>>();
      return list.map(BusySlot.fromJson).toList();
    } on DioException catch (e) {
      throw _toApi(e);
    }
  }

  /// POST /bookings
  Future<CreatedBooking> createBooking({
    required String fieldId,
    required DateTime startTime,
    required DateTime endTime,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/bookings',
        data: {
          'field_id': fieldId,
          'start_time': startTime.toUtc().toIso8601String(),
          'end_time': endTime.toUtc().toIso8601String(),
          'payment_method': paymentMethod.value,
        },
      );
      return CreatedBooking.fromJson(resp.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toApi(e);
    }
  }

  /// POST /bookings/mock-payment
  Future<String> mockPayment({required String bookingId}) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/bookings/mock-payment',
        data: {'booking_id': bookingId},
      );
      return resp.data['message']?.toString() ?? 'Thanh toán mô phỏng thành công';
    } on DioException catch (e) {
      throw _toApi(e);
    }
  }

  /// GET /bookings/history
  Future<List<Booking>> getMyHistory() async {
    try {
      final resp = await _api.raw.get<dynamic>('/bookings/history');
      final list = (resp.data['result'] as List).cast<Map<String, dynamic>>();
      return list.map(Booking.fromJson).toList();
    } on DioException catch (e) {
      throw _toApi(e);
    }
  }

  /// POST /bookings/cancel
  Future<CancelBookingResult> cancelBooking({required String bookingId}) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/bookings/cancel',
        data: {'booking_id': bookingId},
      );
      return CancelBookingResult.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toApi(e);
    }
  }

  /// POST /bookings/reschedule
  Future<RescheduleBookingResult> rescheduleBooking({
    required String bookingId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/bookings/reschedule',
        data: {
          'booking_id': bookingId,
          'start_time': startTime.toUtc().toIso8601String(),
          'end_time': endTime.toUtc().toIso8601String(),
        },
      );
      return RescheduleBookingResult.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toApi(e);
    }
  }

  /// POST /bookings/check-in (admin)
  Future<String> checkIn({required String bookingId}) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/bookings/check-in',
        data: {'booking_id': bookingId},
      );
      return resp.data['message']?.toString() ?? 'Check-in thành công';
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