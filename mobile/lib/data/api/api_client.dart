import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.178.150:8000');
const _tokenKey = 'bloomly_access_token';

/// Refresh the token when it is within this window of expiring (or already expired).
const _refreshThreshold = Duration(seconds: 60);

const _storage = FlutterSecureStorage();

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  late final Dio _dio;

  /// Called when the session can no longer be kept alive (refresh failed or a
  /// request came back 401). The app layer wires this to clear auth state and
  /// navigate back to the login screen. Invoked at most once per dead session.
  void Function()? onSessionExpired;

  /// Single-flight guard so that concurrent requests trigger only one refresh.
  Future<bool>? _refreshCall;

  /// Ensures [onSessionExpired] fires only once until a new token is saved.
  bool _sessionExpiredFired = false;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Auth endpoints (login/signup/refresh) must not pre-attach or refresh.
        if (_isAuthPath(options.path)) {
          return handler.next(options);
        }

        final token = await _storage.read(key: _tokenKey);
        if (token == null) {
          // No session — let the request go; the backend will 401 if it must.
          return handler.next(options);
        }

        // Proactive silent refresh: if the token is expired or about to expire,
        // swap it for a fresh one before the request goes out.
        if (_isExpiringSoon(token)) {
          final refreshed = await _refreshOnce();
          if (!refreshed) {
            await _handleSessionExpired();
            return handler.reject(DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: 'session_expired',
            ));
          }
        }

        final current = await _storage.read(key: _tokenKey);
        if (current != null) {
          options.headers['Authorization'] = 'Bearer $current';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Safety net: a 401 we didn't anticipate (token revoked, secret rotated,
        // or expired past refresh) means the session is dead — bounce to login.
        if (error.response?.statusCode == 401 && !_isAuthPath(error.requestOptions.path)) {
          await _handleSessionExpired();
        }
        handler.next(error);
      },
    ));
  }

  bool _isAuthPath(String path) => path.contains('/auth/');

  /// Runs a refresh, coalescing concurrent callers onto a single network call.
  Future<bool> _refreshOnce() {
    return _refreshCall ??= _refresh().whenComplete(() => _refreshCall = null);
  }

  /// Calls the backend refresh endpoint with the current token. Uses a bare Dio
  /// instance (no interceptors) to avoid recursing back through this logic.
  Future<bool> _refresh() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return false;
    try {
      final bare = Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ));
      final res = await bare.post<Map<String, dynamic>>(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final newToken = res.data?['access_token'] as String?;
      if (newToken == null) return false;
      await saveToken(newToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleSessionExpired() async {
    await clearToken();
    if (_sessionExpiredFired) return;
    _sessionExpiredFired = true;
    onSessionExpired?.call();
  }

  /// Returns true when [token] expires within [_refreshThreshold] (or already
  /// has). If the expiry can't be read, returns false so the server decides.
  bool _isExpiringSoon(String token) {
    final exp = _jwtExpiry(token);
    if (exp == null) return false;
    return DateTime.now().toUtc().add(_refreshThreshold).isAfter(exp);
  }

  /// Decodes the `exp` claim from a JWT without verifying the signature.
  DateTime? _jwtExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final map = jsonDecode(utf8.decode(base64.decode(payload))) as Map<String, dynamic>;
      final exp = map['exp'];
      if (exp is! int) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    // A fresh token means the session is alive again.
    _sessionExpiredFired = false;
  }

  Future<void> clearToken() => _storage.delete(key: _tokenKey);
  Future<bool> hasToken() async => (await _storage.read(key: _tokenKey)) != null;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data, FormData? formData}) =>
      _dio.post<T>(path, data: formData ?? data);

  Future<Response<T>> patch<T>(String path, {dynamic data}) => _dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}
