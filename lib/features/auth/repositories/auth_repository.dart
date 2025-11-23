import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    ref.watch(apiServiceProvider),
    ref.watch(storageServiceProvider),
  );
});

class AuthRepository {
  final ApiService _api;
  final StorageService _storage;

  AuthRepository(this._api, this._storage);

  Future<void> login(String email, String password) async {
    try {
      final response = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data;
      await _storage.setTokens(data['accessToken'], data['refreshToken']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await _api.post('/auth/register', data: {
        'email': email,
        'password': password,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _storage.clearTokens();
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      return e.response?.data['error'] ?? 'Network Error';
    }
    return e.toString();
  }
}