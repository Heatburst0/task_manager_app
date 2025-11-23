import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';

final apiServiceProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiService(storage);
});

class ApiService {
  final StorageService _storage;
  late final Dio _dio;

  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator
  static const String _baseUrl = 'http://10.0.2.2:3000';

  ApiService(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    // Add Interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // If 401 Unauthorized, try to refresh token
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          print("🔴 401 Error Detected: Access Token Expired!");
          try {
            print("🔄 Attempting to refresh token...");
            final newAccessToken = await _refreshToken();
            if (newAccessToken != null) {
              // Retry the original request with new token
              print("✅ Refresh Successful! Retrying original request...");
              e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final cloneReq = await _dio.fetch(e.requestOptions);
              return handler.resolve(cloneReq);
            }
          } catch (_) {
            // Refresh failed, user session is invalid
            print("❌ Refresh Failed. Logging out.");
            await _storage.clearTokens();
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      // Use a new Dio instance to avoid circular interceptors
      final dio = Dio(BaseOptions(baseUrl: _baseUrl));
      final response = await dio.post('/auth/refresh', data: {
        'token': refreshToken
      });

      final newAccess = response.data['accessToken'];
      // Note: We keep the old refresh token unless the server rotates it
      await _storage.setTokens(newAccess, refreshToken);
      return newAccess;
    } catch (e) {
      return null;
    }
  }

  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) => _dio.get(path, queryParameters: queryParameters);
  Future<Response> patch(String path, {dynamic data}) => _dio.patch(path, data: data);
  Future<Response> delete(String path) => _dio.delete(path);
}