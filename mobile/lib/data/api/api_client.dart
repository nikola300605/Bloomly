import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kReleaseMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Compile-time override for the backend address. When set, it is used as-is
/// (no probing) — required for release builds and LAN/remote backends:
///   flutter run --dart-define=API_BASE_URL=http://<host>:8000
const _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

/// Candidates probed (in order) against GET /health in debug builds when no
/// API_BASE_URL is given, so the same build works on any local target:
/// - localhost reaches the host through an adb reverse tunnel on both
///   emulators and USB-connected phones. The tunnel is created automatically
///   by the `adbReverse` Gradle task on every debug build (and by
///   mobile/run-phone.ps1); it drops when the cable is unplugged.
/// - 10.0.2.2 is the emulator-only host alias, kept as a tunnel-less fallback.
const _candidateBaseUrls = ['http://localhost:8000', 'http://10.0.2.2:8000'];

const _initialBaseUrl =
    _definedBaseUrl != '' ? _definedBaseUrl : 'http://localhost:8000';
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

  /// Whether the base URL must be discovered by probing (debug builds with no
  /// explicit API_BASE_URL). Cleared again after connection failures so a
  /// dropped adb tunnel triggers a fresh probe on the next request.
  bool _baseUrlVerified = false;

  /// Single-flight guard so concurrent requests trigger only one probe.
  Future<void>? _probeCall;

  static const bool _probingEnabled = !kReleaseMode && _definedBaseUrl == '';

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _initialBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        await _ensureBaseUrl();
        // The probe may have re-pointed the client after this request's
        // options were already created — keep them in line.
        options.baseUrl = _dio.options.baseUrl;

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
        // The backend became unreachable — the adb tunnel may have dropped or
        // the app moved to a different target. Probe again on the next request.
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout) {
          _baseUrlVerified = false;
        }

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

  /// In debug builds without an explicit API_BASE_URL, finds a reachable
  /// backend before the first request (and again after connection failures).
  /// Coalesces concurrent callers onto a single probe.
  Future<void> _ensureBaseUrl() {
    if (!_probingEnabled || _baseUrlVerified) return Future.value();
    return _probeCall ??= _probeBaseUrl().whenComplete(() => _probeCall = null);
  }

  Future<void> _probeBaseUrl() async {
    for (final base in _candidateBaseUrls) {
      if (await _isReachable(base)) {
        _dio.options.baseUrl = base;
        _baseUrlVerified = true;
        debugPrint('ApiClient: backend found at $base');
        return;
      }
    }
    // Nothing answered — keep the current URL so the request fails with a
    // normal connection error (surfaced as a friendly message), and probe
    // again on the next request.
    debugPrint('ApiClient: no backend reachable (tried $_candidateBaseUrls) — '
        'is the adb reverse tunnel up? (mobile/run-phone.ps1 restores it)');
  }

  Future<bool> _isReachable(String base) async {
    try {
      final bare = Dio(BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ));
      final res = await bare.get<void>('/health');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

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
        baseUrl: _dio.options.baseUrl,
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
