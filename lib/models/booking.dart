import 'package:flutter/material.dart' show Color;

// =====================================================================
// BOOKING STATUS
// =====================================================================
enum BookingStatus { pending, confirmed, cancelled }

extension BookingStatusX on BookingStatus {
  int get value {
    switch (this) {
      case BookingStatus.pending:   return 0;
      case BookingStatus.confirmed: return 1;
      case BookingStatus.cancelled: return 2;
    }
  }

  String get label {
    switch (this) {
      case BookingStatus.pending:   return 'Đang chờ';
      case BookingStatus.confirmed: return 'Đã xác nhận';
      case BookingStatus.cancelled: return 'Đã hủy';
    }
  }

  static BookingStatus fromInt(int? v) {
    switch (v) {
      case 1: return BookingStatus.confirmed;
      case 2: return BookingStatus.cancelled;
      default: return BookingStatus.pending;
    }
  }
}

// =====================================================================
// PAYMENT METHOD
// =====================================================================
enum PaymentMethod { cash, transfer }

extension PaymentMethodX on PaymentMethod {
  int get value => this == PaymentMethod.cash ? 0 : 1;
  String get label => this == PaymentMethod.cash ? 'Tiền mặt' : 'Chuyển khoản';
}

// =====================================================================
// BOOKING - UI model (hien thi tren man hinh danh sach)
// =====================================================================
class Booking {
  final String id;
  final String stadiumName;
  final String address;
  final String dateLabel;
  final String timeLabel;
  final double price;
  final BookingStatus status;
  final Color color;
  final PaymentMethod paymentMethod;
  final double? discountAmount;
  final String? fieldId;

  const Booking({
    required this.id,
    required this.stadiumName,
    required this.address,
    required this.dateLabel,
    required this.timeLabel,
    required this.price,
    required this.status,
    required this.color,
    this.paymentMethod = PaymentMethod.transfer,
    this.discountAmount,
    this.fieldId,
  });

  /// Tao Booking tu response API (GET /bookings/history)
  factory Booking.fromJson(Map<String, dynamic> json) {
    final fi = json['field_info'] as Map<String, dynamic>?;

    final startUtc = DateTime.parse(json['start_time'].toString()).toLocal();
    final endUtc = DateTime.parse(json['end_time'].toString()).toLocal();

    final dateStr =
        '${startUtc.day.toString().padLeft(2, '0')}/${startUtc.month.toString().padLeft(2, '0')}/${startUtc.year}';
    final timeStr =
        '${startUtc.hour.toString().padLeft(2, '0')}:${startUtc.minute.toString().padLeft(2, '0')} - '
        '${endUtc.hour.toString().padLeft(2, '0')}:${endUtc.minute.toString().padLeft(2, '0')}';

    final fieldType = (fi?['type'] as num?)?.toInt() ?? 5;
    final color = fieldType == 7
        ? const Color(0xFF2E7D32)
        : const Color(0xFF1565C0);

    return Booking(
      id: json['_id']?.toString() ?? '',
      stadiumName: fi?['name']?.toString() ?? 'Sân bóng',
      address: fieldType == 7 ? 'Sân 7 người' : 'Sân 5 người',
      dateLabel: dateStr,
      timeLabel: timeStr,
      price: (json['final_price'] as num?)?.toDouble() ?? 0,
      status: BookingStatusX.fromInt((json['status'] as num?)?.toInt()),
      color: color,
      paymentMethod:
          ((json['payment_method'] as num?)?.toInt() ?? 1) == 0
              ? PaymentMethod.cash
              : PaymentMethod.transfer,
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      fieldId: json['field_id']?.toString(),
    );
  }
}

// =====================================================================
// BUSY SLOT - response tu GET /bookings/busy-slots
// =====================================================================
class BusySlot {
  final DateTime startTime;
  final DateTime endTime;
  final int status;

  const BusySlot({
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory BusySlot.fromJson(Map<String, dynamic> json) => BusySlot(
        startTime: DateTime.parse(json['start_time'].toString()).toLocal(),
        endTime: DateTime.parse(json['end_time'].toString()).toLocal(),
        status: (json['status'] as num?)?.toInt() ?? 0,
      );
}

// =====================================================================
// CREATED BOOKING - response tu POST /bookings
// =====================================================================
class CreatedBooking {
  final String id;
  final double basePrice;
  final double discountAmount;
  final double finalPrice;
  final int status;
  final String fieldId;
  final DateTime startTime;
  final DateTime endTime;

  const CreatedBooking({
    required this.id,
    required this.basePrice,
    required this.discountAmount,
    required this.finalPrice,
    required this.status,
    required this.fieldId,
    required this.startTime,
    required this.endTime,
  });

  factory CreatedBooking.fromJson(Map<String, dynamic> json) {
    return CreatedBooking(
      id: json['_id']?.toString() ?? '',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['final_price'] as num?)?.toDouble() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      fieldId: json['field_id']?.toString() ?? '',
      startTime: DateTime.parse(json['start_time'].toString()).toLocal(),
      endTime: DateTime.parse(json['end_time'].toString()).toLocal(),
    );
  }
}

// =====================================================================
// CANCEL RESULT - response tu POST /bookings/cancel
// =====================================================================
class CancelBookingResult {
  final String message;
  final double refundAmount;
  final String bookingId;

  const CancelBookingResult({
    required this.message,
    required this.refundAmount,
    required this.bookingId,
  });

  factory CancelBookingResult.fromJson(Map<String, dynamic> json) =>
      CancelBookingResult(
        message: json['message']?.toString() ?? '',
        refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0,
        bookingId: json['booking_id']?.toString() ?? '',
      );
}

// =====================================================================
// RESCHEDULE RESULT - response tu POST /bookings/reschedule
// =====================================================================
class RescheduleBookingResult {
  final String message;
  final String bookingId;
  final DateTime newStartTime;
  final DateTime newEndTime;

  const RescheduleBookingResult({
    required this.message,
    required this.bookingId,
    required this.newStartTime,
    required this.newEndTime,
  });

  factory RescheduleBookingResult.fromJson(Map<String, dynamic> json) =>
      RescheduleBookingResult(
        message: json['message']?.toString() ?? '',
        bookingId: json['booking_id']?.toString() ?? '',
        newStartTime: DateTime.parse(json['new_start_time'].toString()).toLocal(),
        newEndTime: DateTime.parse(json['new_end_time'].toString()).toLocal(),
      );
}

// =====================================================================
// ADMIN REVENUE - response tu GET /admin/revenue
// =====================================================================
class Revenue {
  final double totalRevenue;
  final double cashRevenue;
  final double transferRevenue;
  final int totalBookings;

  const Revenue({
    required this.totalRevenue,
    required this.cashRevenue,
    required this.transferRevenue,
    required this.totalBookings,
  });

  factory Revenue.fromJson(Map<String, dynamic> json) => Revenue(
        totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
        cashRevenue: (json['cash_revenue'] as num?)?.toDouble() ?? 0,
        transferRevenue: (json['transfer_revenue'] as num?)?.toDouble() ?? 0,
        totalBookings: (json['total_bookings'] as num?)?.toInt() ?? 0,
      );
}

// =====================================================================
// ADMIN BOOKING - response tu GET /admin/bookings/daily
// =====================================================================
class AdminBooking {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double finalPrice;
  final int status;
  final int paymentMethod;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? fieldName;
  final int? fieldType;

  const AdminBooking({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.finalPrice,
    required this.status,
    required this.paymentMethod,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.fieldName,
    this.fieldType,
  });

  factory AdminBooking.fromJson(Map<String, dynamic> json) {
    final ui = json['user_info'] as Map<String, dynamic>?;
    final fi = json['field_info'] as Map<String, dynamic>?;
    return AdminBooking(
      id: json['_id']?.toString() ?? '',
      startTime: DateTime.parse(json['start_time'].toString()).toLocal(),
      endTime: DateTime.parse(json['end_time'].toString()).toLocal(),
      finalPrice: (json['final_price'] as num?)?.toDouble() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      paymentMethod: (json['payment_method'] as num?)?.toInt() ?? 1,
      userName: ui?['name']?.toString(),
      userEmail: ui?['email']?.toString(),
      userPhone: ui?['phone_number']?.toString(),
      fieldName: fi?['name']?.toString(),
      fieldType: (fi?['type'] as num?)?.toInt(),
    );
  }
}

// =====================================================================
// MOCK DATA - booking cua man hinh danh sach (truoc khi goi API)
// =====================================================================

final List<Booking> sampleBookings = [
  Booking(
    id: 'b1',
    stadiumName: 'Sân Bóng Thống Nhất',
    address: '123 Nguyễn Trãi, Quận 5',
    dateLabel: '15/06/2026',
    timeLabel: '18:00 - 19:30',
    price: 525000,
    status: BookingStatus.confirmed,
    color: const Color(0xFF2E7D32),
    paymentMethod: PaymentMethod.transfer,
  ),
  Booking(
    id: 'b2',
    stadiumName: 'Sân Bóng Phú Thọ',
    address: '215 Lý Thường Kiệt, Quận 11',
    dateLabel: '18/06/2026',
    timeLabel: '20:00 - 21:30',
    price: 420000,
    status: BookingStatus.pending,
    color: const Color(0xFF1565C0),
    paymentMethod: PaymentMethod.transfer,
  ),
  Booking(
    id: 'b3',
    stadiumName: 'Sân Bóng Hoàng Anh Gia Lai',
    address: '50 Trường Chinh, Tân Bình',
    dateLabel: '22/06/2026',
    timeLabel: '07:30 - 09:00',
    price: 675000,
    status: BookingStatus.cancelled,
    color: const Color(0xFFE65100),
    paymentMethod: PaymentMethod.cash,
  ),
];
