import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String fallbackUrl = 'https://trading-wsxw.onrender.com';
  
  // Read base URL dynamically from environment if defined
  static final String baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: fallbackUrl);

  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle global network exceptions here if needed
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data != null) {
        try {
          if (data is Map && data.containsKey('message') && data['message'] is Map) {
            final errorMap = data['message'] as Map;
            if (errorMap.containsKey('error') && errorMap['error'] is List) {
              return (errorMap['error'] as List).join('\n');
            }
          }
        } catch (_) {}
      }
      switch (error.response?.statusCode) {
        case 400:
          return 'Bad request. Please verify inputs.';
        case 401:
          return 'Unauthorized session. Please login again.';
        case 403:
          return 'Action forbidden.';
        case 404:
          return 'Resource not found on server.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Something went wrong (HTTP ${error.response?.statusCode}).';
      }
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Network timeout. Check your internet connection.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to the server.';
      default:
        return 'Network connection failed.';
    }
  }
}
