import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/review.dart';

class ReviewService {
  final ApiClient _api = ApiClient.instance;

  Future<Review> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final resp = await _api.raw.post<dynamic>(
        '/reviews',
        data: {
          'booking_id': bookingId,
          'rating': rating,
          if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
        },
      );
      final reviewJson = (resp.data['review'] as Map<String, dynamic>?) ?? {};
      return Review.fromJson(reviewJson);
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
