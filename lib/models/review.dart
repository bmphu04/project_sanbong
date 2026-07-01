/// Model Review (response từ POST /reviews)
class Review {
  final String id;
  final String bookingId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['_id']?.toString() ?? '',
        bookingId: json['booking_id']?.toString() ?? '',
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString()).toLocal()
            : DateTime.now(),
      );
}