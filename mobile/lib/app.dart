import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/api/api_client.dart';
import 'features/auth/providers/auth_provider.dart';

class BloomlyApp extends ConsumerWidget {
  const BloomlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wire the session-expiry handler: when the API client can no longer keep
    // the session alive, drop auth state, bounce to login, and tell the user.
    // Assigning the closure here is idempotent across rebuilds.
    ref.read(apiClientProvider).onSessionExpired = () {
      ref.read(authProvider.notifier).handleSessionExpired();
      appRouter.go(AppRoutes.login);
      rootScaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Your session expired. Please log in again.')),
        );
    };

    return MaterialApp.router(
      title: 'Bloomly',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
    );
  }
}
