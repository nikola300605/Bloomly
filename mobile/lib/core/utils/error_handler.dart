import 'package:dio/dio.dart';

/// Maps any thrown error (usually a [DioException]) to a short, friendly,
/// user-facing message. Never returns a stack trace, a raw exception string,
/// or a bare status code.
String friendlyError(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is DioException) {
    // The API client rejects requests with this when the session can no longer
    // be refreshed; the user is being sent to login in parallel.
    if (error.type == DioExceptionType.cancel && error.error == 'session_expired') {
      return 'Your session expired. Please log in again.';
    }

    // Prefer a server-provided detail when it's short and human-readable.
    final data = error.response?.data;
    if (data is Map && data['detail'] is String) {
      final detail = (data['detail'] as String).trim();
      if (detail.isNotEmpty && detail.length <= 120) return detail;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The connection timed out. Check your network and try again.';
      case DioExceptionType.connectionError:
        return "Couldn't reach the server. Check your connection and try again.";
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode ?? 0;
        if (code == 404) return "We couldn't find what you were looking for.";
        if (code == 401 || code == 403) return 'Please log in to continue.';
        if (code >= 500) return 'The server had a problem. Please try again shortly.';
        return fallback;
      default:
        return fallback;
    }
  }
  return fallback;
}
