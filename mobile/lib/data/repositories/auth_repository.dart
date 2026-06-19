import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  final ApiClient _api;
  AuthRepository(this._api);

  Future<String> loginWithEmail({required String email, required String password}) async {
    final response = await _api.post('/auth/email/login', data: {'email': email, 'password': password});
    final token = response.data['access_token'] as String;
    await _api.saveToken(token);
    return response.data['user_id'] as String;
  }

  Future<String> signupWithEmail({
    required String email,
    required String password,
    required String name,
    required String handle,
  }) async {
    final response = await _api.post('/auth/email/signup', data: {
      'email': email,
      'password': password,
      'name': name,
      'handle': handle,
    });
    final token = response.data['access_token'] as String;
    await _api.saveToken(token);
    return response.data['user_id'] as String;
  }

  Future<void> logout() => _api.clearToken();

  Future<bool> isLoggedIn() => _api.hasToken();

  Future<String> loginWithGoogle(String idToken) async {
    final response = await _api.post('/auth/google', data: {'id_token': idToken});
    final token = response.data['access_token'] as String;
    await _api.saveToken(token);
    return response.data['user_id'] as String;
  }
}
