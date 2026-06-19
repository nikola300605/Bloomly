import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../data/api/api_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({this.status = AuthStatus.unknown, this.user, this.error});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) => AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final ApiClient _api;

  AuthNotifier(this._repo, this._api) : super(const AuthState()) {
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final loggedIn = await _repo.isLoggedIn();
    if (loggedIn) {
      try {
        final res = await _api.get('/users/me');
        final user = UserModel.fromJson(res.data as Map<String, dynamic>);
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } catch (_) {
        await _repo.logout();
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _repo.loginWithEmail(email: email, password: password);
      final res = await _api.get('/users/me');
      final user = UserModel.fromJson(res.data as Map<String, dynamic>);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
      rethrow;
    }
  }

  Future<void> signupWithEmail({
    required String email,
    required String password,
    required String name,
    required String handle,
  }) async {
    try {
      await _repo.signupWithEmail(
        email: email,
        password: password,
        name: name,
        handle: handle,
      );
      final res = await _api.get('/users/me');
      final user = UserModel.fromJson(res.data as Map<String, dynamic>);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    final googleUser = await GoogleSignIn(
      serverClientId: '576558682249-rub4eahqpun1m610pd9ee793mi13t5fq.apps.googleusercontent.com',
    ).signIn();
    if (googleUser == null) return;
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('No Google ID token');
    }

    await _repo.loginWithGoogle(idToken);
    final res = await _api.get('/users/me');
    final user = UserModel.fromJson(res.data as Map<String, dynamic>);
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Called when the API client determines the session can no longer be
  /// refreshed. The token has already been cleared by the client; here we just
  /// drop the in-memory auth state so the app reflects the logged-out status.
  void handleSessionExpired() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(apiClientProvider),
  );
});
