import 'package:flutter/material.dart';

/// A friendly, reusable error state with an optional retry action.
///
/// Use wherever an async load can fail (plant list, feed, plant detail, …) so
/// the user sees a plain-English message instead of a blank screen or a raw
/// exception. Colours come from the theme — error text uses
/// `colorScheme.error`, the retry button uses the app's primary button style.
class ErrorPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorPlaceholder({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 44, color: cs.error),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.error),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 168,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
