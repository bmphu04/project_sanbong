import 'package:flutter/material.dart' show Color;

enum BookingStatus { pending, confirmed, cancelled }

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Đang chờ';
      case BookingStatus.confirmed:
        return 'Đã xác nhận';
      case BookingStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

class Booking {
  final String id;
  final String stadiumName;
  final String address;
  final String dateLabel;
  final String timeLabel;
  final double price;
  final BookingStatus status;
  final Color color;

  const Booking({
    required this.id,
    required this.stadiumName,
    required this.address,
    required this.dateLabel,
    required this.timeLabel,
    required this.price,
    required this.status,
    required this.color,
  });
}

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
  ),
];