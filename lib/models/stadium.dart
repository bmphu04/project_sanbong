import 'package:flutter/material.dart';

class Stadium {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final double pricePerHour;
  final String category;
  final List<String> amenities;
  final List<TimeSlot> timeSlots;
  final Color imageColor;
  final String imageLabel;

  const Stadium({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.pricePerHour,
    required this.category,
    required this.amenities,
    required this.timeSlots,
    required this.imageColor,
    required this.imageLabel,
  });
}

class TimeSlot {
  final String start;
  final String end;
  final bool available;

  const TimeSlot({
    required this.start,
    required this.end,
    required this.available,
  });

  String get label => '$start - $end';
}

const List<Stadium> sampleStadiums = [
  Stadium(
    id: 's1',
    name: 'Sân Bóng Thống Nhất',
    address: '123 Nguyễn Trãi, Quận 5, TP.HCM',
    rating: 4.8,
    reviewCount: 234,
    pricePerHour: 350000,
    category: 'Sân 7 người',
    amenities: ['Giữ xe', 'Nước uống', 'Tủ đồ', 'WiFi'],
    timeSlots: [
      TimeSlot(start: '07:00', end: '08:30', available: true),
      TimeSlot(start: '08:30', end: '10:00', available: true),
      TimeSlot(start: '15:00', end: '16:30', available: true),
      TimeSlot(start: '16:30', end: '18:00', available: false),
      TimeSlot(start: '18:00', end: '19:30', available: true),
      TimeSlot(start: '19:30', end: '21:00', available: false),
      TimeSlot(start: '21:00', end: '22:30', available: true),
    ],
    imageColor: Color(0xFF2E7D32),
    imageLabel: 'Sân 7',
  ),
  Stadium(
    id: 's2',
    name: 'Sân Bóng Phú Thọ',
    address: '215 Lý Thường Kiệt, Quận 11, TP.HCM',
    rating: 4.6,
    reviewCount: 187,
    pricePerHour: 280000,
    category: 'Sân 5 người',
    amenities: ['Giữ xe', 'Nước uống', 'Tủ đồ'],
    timeSlots: [
      TimeSlot(start: '07:00', end: '08:30', available: true),
      TimeSlot(start: '08:30', end: '10:00', available: false),
      TimeSlot(start: '17:00', end: '18:30', available: true),
      TimeSlot(start: '18:30', end: '20:00', available: true),
      TimeSlot(start: '20:00', end: '21:30', available: false),
    ],
    imageColor: Color(0xFF1565C0),
    imageLabel: 'Sân 5',
  ),
  Stadium(
    id: 's3',
    name: 'Sân Bóng Hoàng Anh Gia Lai',
    address: '50 Trường Chinh, Quận Tân Bình, TP.HCM',
    rating: 4.9,
    reviewCount: 412,
    pricePerHour: 450000,
    category: 'Sân 7 người',
    amenities: ['Giữ xe', 'Nước uống', 'Tủ đồ', 'WiFi', 'Căng tin'],
    timeSlots: [
      TimeSlot(start: '06:00', end: '07:30', available: true),
      TimeSlot(start: '07:30', end: '09:00', available: true),
      TimeSlot(start: '17:00', end: '18:30', available: false),
      TimeSlot(start: '18:30', end: '20:00', available: false),
      TimeSlot(start: '20:00', end: '21:30', available: true),
    ],
    imageColor: Color(0xFFE65100),
    imageLabel: 'Sân 7',
  ),
  Stadium(
    id: 's4',
    name: 'Sân Bóng Rạch Miễu',
    address: '88 Phan Xích Long, Quận Phú Nhuận, TP.HCM',
    rating: 4.5,
    reviewCount: 96,
    pricePerHour: 220000,
    category: 'Sân 5 người',
    amenities: ['Giữ xe', 'Nước uống'],
    timeSlots: [
      TimeSlot(start: '08:00', end: '09:30', available: true),
      TimeSlot(start: '16:00', end: '17:30', available: true),
      TimeSlot(start: '17:30', end: '19:00', available: false),
      TimeSlot(start: '19:00', end: '20:30', available: true),
    ],
    imageColor: Color(0xFF6A1B9A),
    imageLabel: 'Sân 5',
  ),
];