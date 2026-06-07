import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/utils/error_handler.dart';
import '../../data/repositories/plant_repository.dart';
import '../home/providers/plants_provider.dart';

/// Creates a plant from [payload], refreshes the plant list, and on success
/// navigates to the new plant's detail screen with a confirmation snackbar.
///
/// Returns `null` on success, or a friendly error message on failure (the
/// caller should surface it). [context] must still be mounted on success for
/// navigation; pass [displayName] for the snackbar text.
Future<String?> addPlantFromPayload(
  WidgetRef ref,
  BuildContext context,
  Map<String, dynamic> payload, {
  required String displayName,
}) async {
  try {
    final plant = await ref.read(plantRepositoryProvider).createPlant(payload);
    ref.invalidate(plantsProvider);
    if (context.mounted) {
      context.go('/home/plants/${plant.id}');
      rootScaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Added $displayName to your plants 🌱')),
        );
    }
    return null;
  } catch (e) {
    return friendlyError(e, fallback: "Couldn't add the plant. Please try again.");
  }
}
