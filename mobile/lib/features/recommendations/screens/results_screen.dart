import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/care_badge.dart';

/// Variation C — plant match % results after the quiz.
class QuizResultsScreen extends StatelessWidget {
  final Map<String, dynamic> answers;

  const QuizResultsScreen({super.key, required this.answers});

  // Stub matches — replace with real API call using quiz answers
  static const _matches = [
    _Match('🌿', 'Pothos', 98, 'thrives low light · trailing · very forgiving'),
    _Match('🪴', 'Spider plant', 94, 'cat-safe · fast-growing · easy'),
    _Match('🌱', 'Calathea', 88, 'pet-safe · beautiful patterned leaves'),
    _Match('🌵', 'Snake plant', 85, 'extremely low maintenance · air purifying'),
    _Match('🌷', 'Peace lily', 79, 'low light · white blooms · cat-toxic ⚠'),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final summary = answers.entries.map((e) => e.value).join(' · ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.pop(),
            tooltip: 'Redo quiz',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
        children: [
          // Summary chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: RichText(
              text: TextSpan(
                style: tt.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                children: [
                  TextSpan(text: 'Based on: ', style: tt.titleLarge?.copyWith(fontSize: 13)),
                  TextSpan(text: summary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          ..._matches.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.accentMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text(m.emoji, style: const TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(m.name, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                const Spacer(),
                                CareBadge(kind: 'ok', label: '${m.match}% match'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(m.why, style: tt.labelSmall),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 30),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    textStyle: const TextStyle(fontSize: 11),
                                  ),
                                  child: const Text('learn'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => context.push(AppRoutes.addPlant),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(0, 30),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    textStyle: const TextStyle(fontSize: 11),
                                  ),
                                  child: const Text('+ add'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'show more results',
                style: tt.bodySmall?.copyWith(decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Match {
  final String emoji;
  final String name;
  final int match;
  final String why;

  const _Match(this.emoji, this.name, this.match, this.why);
}
