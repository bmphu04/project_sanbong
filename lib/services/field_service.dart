import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/stadium.dart';

class FieldService {
  final ApiClient _api = ApiClient.instance;

  Future<List<Field>> getAllFields() async {
    try {
      final resp = await _api.raw.get<dynamic>('/fields');
      final list = (resp.data['result'] as List).cast<Map<String, dynamic>>();
      return list.map(Field.fromJson).toList();
    } on DioException catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(DioException e) {
    final err = e.error;
    if (err is ApiException) return err;
    return ApiException(statusCode: 0, message: 'Không thể tải danh sách sân');
  }
}
