import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio dio;

  ApiClient({String? overrideBaseUrl})
      : dio = Dio(
          BaseOptions(
            // Default to localhost:5001 matching backend, fallbacks for Android emulator loopback
            baseUrl: overrideBaseUrl ?? 'http://localhost:5001/api/v1',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('access_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {
            // Silently fail if local storage is not initialized
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Custom mapped network errors can be structured here
          return handler.next(error);
        },
      ),
    );
  }
}
