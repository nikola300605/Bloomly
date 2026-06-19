// Live connectivity check: requires the local Docker backend (docker compose
// up) and seeded demo data, so it is skipped by default. When the app can't
// reach the backend, run it to tell apart "backend down" from "device can't
// reach the PC":
//   flutter test --run-skipped test/api_probe_live_test.dart
import 'package:bloomly/data/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('probe finds the local backend and login succeeds',
      skip: 'live test — needs the local backend; run with --run-skipped',
      () async {
    final api = ApiClient();
    final res = await api.post<Map<String, dynamic>>(
      '/auth/email/login',
      data: {'email': 'demo@bloomly.app', 'password': 'demo1234'},
    );
    expect(res.statusCode, 200);
    expect(res.data?['access_token'], isNotNull);
  });
}
