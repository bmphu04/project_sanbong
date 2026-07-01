library;

import 'package:flutter/material.dart' show Color;

class Field {
  final String id;
  final String name;
  final int type; // 5 = san 5 nguoi, 7 = san 7 nguoi
  final double pricePerHour;
  final bool isActive;
  final List<String> amenities;
  final List<String> linkedFieldIds;
  final String openingTime;
  final String closingTime;

  const Field({
    required this.id,
    required this.name,
    required this.type,
    required this.pricePerHour,
    required this.isActive,
    required this.amenities,
    required this.linkedFieldIds,
    required this.openingTime,
    required this.closingTime,
  });

  String get typeLabel => 'Sân $type người';
  String get category => typeLabel;

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: (json['type'] as num?)?.toInt() ?? 5,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      amenities: ((json['amenities'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      linkedFieldIds: ((json['linked_field_ids'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      openingTime: json['opening_time']?.toString() ?? '06:00',
      closingTime: json['closing_time']?.toString() ?? '22:00',
    );
  }

  /// Chuyen doi thanh Stadium (UI model) de truyen vao DetailScreen/StadiumCard.
  Stadium asStadium() => Stadium.fromField(this);
}

/// Model Stadium la UI model su dung boi DetailScreen & StadiumCard.
class Stadium {
  final Field _f;
  const Stadium._(this._f);

  factory Stadium.fromField(Field f) => Stadium._(f);

  // --- Properties map tu Field ---
  String get name => _f.name;
  int get type => _f.type;
  double get pricePerHour => _f.pricePerHour;
  bool get isActive => _f.isActive;
  List<String> get amenities => _f.amenities;
  List<String> get linkedFieldIds => _f.linkedFieldIds;
  String get openingTime => _f.openingTime;
  String get closingTime => _f.closingTime;
  String get typeLabel => _f.typeLabel;
  String get category => _f.category;
  String get id => _f.id;

  // --- UI-specific properties ---
  Color get imageColor => type == 7
      ? const Color(0xFF2E7D32)
      : const Color(0xFF1565C0);

  String get imageLabel => typeLabel;
  List<TimeSlot> get timeSlots => [];
  double get rating => 4.8;
  int get reviewCount => 128;
  String get address => typeLabel;
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

// =====================================================================
// MOCK DATA - danh sach san cua HomeScreen (truoc khi goi API)
// =====================================================================
final List<Stadium> sampleStadiums = [
  Stadium.fromField(const Field(
    id: 'mock1',
    name: 'Sân Bóng Thống Nhất',
    type: 5,
    pricePerHour: 350000,
    isActive: true,
    amenities: ['Nước uống', 'WiFi', 'Giữ xe'],
    linkedFieldIds: [],
    openingTime: '06:00',
    closingTime: '22:00',
  )),
  Stadium.fromField(const Field(
    id: 'mock2',
    name: 'Sân Bóng Phú Thọ',
    type: 7,
    pricePerHour: 550000,
    isActive: true,
    amenities: ['Nước uống', 'Khán đài', 'WiFi'],
    linkedFieldIds: [],
    openingTime: '06:00',
    closingTime: '22:00',
  )),
  Stadium.fromField(const Field(
    id: 'mock3',
    name: 'Sân Bóng Hoàng Anh Gia Lai',
    type: 5,
    pricePerHour: 400000,
    isActive: true,
    amenities: ['WiFi', 'Tủ đồ'],
    linkedFieldIds: [],
    openingTime: '06:00',
    closingTime: '22:00',
  )),
  Stadium.fromField(const Field(
    id: 'mock4',
    name: 'Sân Bóng Rạch Miễu',
    type: 7,
    pricePerHour: 600000,
    isActive: true,
    amenities: ['Nước uống', 'Giữ xe', 'Khán đài'],
    linkedFieldIds: [],
    openingTime: '06:00',
    closingTime: '22:00',
  )),
  Stadium.fromField(const Field(
    id: 'mock5',
    name: 'Sân Bóng Lam Viên',
    type: 5,
    pricePerHour: 300000,
    isActive: true,
    amenities: ['Nước uống'],
    linkedFieldIds: [],
    openingTime: '06:00',
    closingTime: '22:00',
  )),
  Stadium.fromField(const Field(
    id: 'mock6',
    name: 'Sân Bóng Thanh Đa',
    type: 7,
    pricePerHour: 700000,
    isActive: true,
    amenities: ['WiFi', 'Giữ xe', 'Khán đài', 'Tủ đồ'],
    linkedFieldIds: [],
    openingTime: '06:00',
    closingTime: '22:00',
  )),
];
