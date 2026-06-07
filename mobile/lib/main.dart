import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ReminderService.init();
  runApp(
    const ProviderScope(
      child: BloomlyApp(),
    ),
  );
}
