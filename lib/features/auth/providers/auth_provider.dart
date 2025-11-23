import 'package:flutter_riverpod/legacy.dart';
import '../repositories/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  AuthState({this.isLoading = false, this.error});
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthController(this._repo) : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      await _repo.login(email, password);
      state = AuthState(isLoading: false);
      return true;
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      await _repo.register(email, password);
      state = AuthState(isLoading: false);
      return true;
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});