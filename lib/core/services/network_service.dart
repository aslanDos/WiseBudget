import 'package:dio/dio.dart';

class NetworkService {
  NetworkService({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      url,
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data == null) {
      throw DioException.badResponse(
        statusCode: response.statusCode ?? -1,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
    return data;
  }
}
